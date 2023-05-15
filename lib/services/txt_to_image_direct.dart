import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';
import 'package:pool/pool.dart';

import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/image_repository.dart';

class TxtToImageDirect implements TxtToImageInterface {
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final FocusNode focusNode;
  final SystemPreferences systemPreferences;
  final GenerationPreferences generationPreferences;
  late final Pool pool;

  TxtToImageDirect(
    this.playbackState,
    this.imageRepository,
    this.focusNode,
    this.systemPreferences,
    this.generationPreferences,
  ) {
    pool = Pool(systemPreferences.maxThreads,
        timeout: const Duration(seconds: 60));
  }

  final Dio dio = Dio();

  @override
  void startGeneration(
      int index,
      prompt,
      nprompt,
      model,
      sampler,
      cfg,
      steps,
      seed,
      upscale,
      apiKey,
      apiName,
      apiGenerationEndpoint,
      apiFetchEndpoint,
      setState,
      repeatIndex) async {
    if (repeatIndex > 3) {
      return;
    }
    if (kDebugMode) {
      print('starting from $prompt');
    }
    systemPreferences.activeThreads++;
    final placeholderShot = Shot(index.toString(), '', prompt, nprompt, cfg,
        steps, seed, model, sampler, index);
    imageRepository.addShot(index, placeholderShot);

    final data = <String, dynamic>{
      "options": {
        "sd_model_checkpoint": "edgeOfRealism_eorV20Fp16BakedVAE.safetensors"
      },
      "original_prompt": prompt,
      "txt2img": {
        "prompt": prompt,
        "negative_prompt": nprompt,
        "steps": steps,
        "width": 640,
        "height": 512,
        "sampler_name": generationPreferences.samplers[sampler],
        "cfg_scale": cfg,
        "seed": seed
      },
      "sd_user_id": "972bf9cc-72a4-4436-aae3-fa470bab1ec3",
      "sd_session_id": "972bf9cc-72a4-4436-aae3-fa470bab1ec3",
      "columnIndex": 0
    };

    final str = jsonEncode(data);
    final Response<dynamic> result;

    try {
      result = await dio.post(apiGenerationEndpoint,
          data: str,
          options: Options(headers: {
            'accept': 'application/json',
            'content-type': 'application/json'
          }));
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error on job creation \n$e');
      }
      eraseOrRedo(placeholderShot, setState, apiKey, apiName,
          apiGenerationEndpoint, apiFetchEndpoint, repeatIndex, upscale);
      return;
    }

    final resp = jsonDecode(result.toString());
    final String job = resp['id'];
    final earlyShot =
        Shot(job, '', prompt, nprompt, cfg, steps, seed, model, sampler, index);
    imageRepository.addShot(index, earlyShot);

    String base64image = '';
    Future.delayed(const Duration(seconds: 10));

    int r = 0;
    do {
      Response result2;
      try {
        result2 = await dio.get("$apiFetchEndpoint$job",
            options: Options(headers: {
              "sd_user_id": "972bf9cc-72a4-4436-aae3-fa470bab1ec3",
              "sd_session_id": "972bf9cc-72a4-4436-aae3-fa470bab1ec3",
              'accept': 'application/json',
            }));
      } on Exception catch (e) {
        if (kDebugMode) {
          print('error during job retrieving : $e');
        }
        eraseOrRedo(earlyShot, setState, apiKey, apiName, apiGenerationEndpoint,
            apiFetchEndpoint, repeatIndex, upscale);
        return;
      }

      final resp2 = jsonDecode(result2.toString());
      if (kDebugMode) {
        print(result2.toString().substring(0, 244));
      }

      if (resp2.containsKey('jobRec') &&
          resp2['jobRec'].containsKey('response') &&
          resp2['jobRec']['response'] != null &&
          resp2['jobRec']['response'].containsKey('images')) {
        base64image = resp2['jobRec']['response']['images'].first;
      } else {
        if ((resp2['success'] == 'false') ||
            ((r > 7) && (resp2['status'] != 'queued'))) {
          if (kDebugMode) {
            print('failed job with:\n$resp2');
          }
          eraseOrRedo(earlyShot, setState, apiKey, apiName,
              apiGenerationEndpoint, apiFetchEndpoint, repeatIndex, upscale);
          return;
        }
        await Future.delayed(const Duration(seconds: 5));
        if (kDebugMode) {
          print('retry d:$job r=$r');
        }
        r++;
      }
    } while (base64image.isEmpty);

    final updatedShot = Shot(
        job, '/', prompt, nprompt, cfg, steps, seed, model, sampler, index);

    if (kDebugMode) {
      print('FINALIZED SHOT $index');
    }

    final image = Image.memory(
      base64Decode(base64image),
    );
    imageRepository.setImage(index, image);

    imageRepository.addShot(index, updatedShot);
    systemPreferences.activeThreads--;
    setState(() {});
  }

  void eraseOrRedo(Shot s, setState, apiKey, apiName, apiGenerationEnpoint,
      apiFetchEndpoint, repeatIndex, upscale) {
    /*
    systemPreferences.activeThreads--;
    startGeneration(
        s.index,
        s.prompt,
        s.nprompt,
        s.model,
        s.sampler,
        s.cfg,
        s.steps,
        s.seed,
        upscale,
        apiKey,
        apiName,
        apiGenerationEnpoint,
        apiFetchEndpoint,
        setState,
        repeatIndex + 1);
  */
  }

  @override
  void multiSpan(setState, apiKey, apiName, apiGenerationEndpoint,
      apiFetchEndpoint, prompt, nprompt) async {
    playbackState.setAuto(false);
    imageRepository.clearCache();

    playbackState.setPage(0, () {});
    playbackState.setLoading(0.0);
    focusNode.requestFocus();
    systemPreferences.totalrenders = 0;
    setState(() {});
    playbackState.setPage(0, () {});

    var seed = -1;
    if (!generationPreferences.getRandomSeed()) {
      if (seed == -1) {
        seed = Random().nextInt(199999999);
      }
    }

    final upscale = generationPreferences.getUpscale();
    int index = 0;

    for (int method = 0;
        method < generationPreferences.selectedModels.length;
        method++) {
      if (generationPreferences.selectedModels[method]) {
        for (int sampler = 0;
            sampler < generationPreferences.samplers.length;
            sampler++) {
          if (generationPreferences.selectedSamplers[sampler]) {
            for (int cfg = generationPreferences.cfgSliderValue.toInt();
                cfg < generationPreferences.cfgSliderEValue + 1;
                cfg++) {
              for (int steps = generationPreferences.stepSliderValue.toInt();
                  steps < generationPreferences.stepSliderEValue + 1;
                  steps += 1) {
                systemPreferences.totalrenders++;
                pool.withResource(() => startGeneration(
                      index++,
                      prompt,
                      nprompt,
                      method,
                      sampler,
                      cfg,
                      steps,
                      seed,
                      upscale,
                      apiKey,
                      apiName,
                      apiGenerationEndpoint,
                      apiFetchEndpoint,
                      setState,
                      0,
                    ));
                await Future.delayed(const Duration(milliseconds: 5));
              }
            }
          }
        }
      }
    }
  }
}

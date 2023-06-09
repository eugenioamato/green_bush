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
        timeout: const Duration(minutes: 60));
  }

  @override
  List<String> allsamplers() => [
        "DPM++ 2M Karras",
        "DPM++ SDE Karras",
        "DPM++ 2S a Karras",
        "DDIM",
        "DPM++ 2S a",
        "Euler",
        "Euler a",
        "Heun",
      ];

  @override
  allmodels() => [
        "experience_80.safetensors",
        "realisticVisionV20_v20.safetensors",
        "uberRealisticPornMerge_urpmv13.safetensors",
        "hardblend_.safetensors",
        "Degenerate_deliberateV1.safetensors",
        "3moonNIReal_3moonNIRealV2.safetensors",
        "stable-diffusion-2-1/v2-1_768-nonema-pruned.ckpt",
        "crystalClear_v10.safetensors",
        "edgeOfRealism_eorV20Fp16BakedVAE.safetensors",
        "deliberate.TWTR.ckpt",
        "life20like20diffusion.D2sc.safetensors",
        "cineDiffusionV3Half.8epy.safetensors",
        "amirealV2Pruned.XH5l.safetensors",
        "artisanicaV1.iOiq.safetensors",
        "2348Old20fish2012.jr7T.safetensors",
        "revAnimated_v11.safetensors",
        "analogmadnessv4.w480.safetensors",
        "mixrealV2.xje4.safetensors",
        "dreamlike-diffusion-2.0.ckpt",
        "openjourney-v4/openjourney-v4.ckpt",
        "cheeseDaddys_35.safetensors",
        "526mixV14_v14.safetensors",
        "hyperV1_v10.safetensors",
        "lyriel_v15.safetensors",
        "stylejourney_v10.safetensors",
        "realismEngine_v10.safetensors",
        "classicNegativeSD21_classicNegative768px.ckpt",
        "walnutcreamBlend_herbmixV1.safetensors",
        "dreamshaper_4BakedVae.safetensors",
        "stable-diffusion-v1-5/v1-5-pruned-emaonly.ckpt",
        "chilloutmix_NiPrunedFp32Fix.safetensors",
        "timeless-1.0.ckpt",
        "portrait+1.0.ckpt",
        "Analog-Diffusion/analog-diffusion-1.0.ckpt",
        "stable-diffusion-2-1/v2-1_768-nonema-pruned.ckpt",
        "Counterfeit-V2.5/Counterfeit-V2.5_fp16.safetensors",
      ];

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
      apiSession,
      apiSessionName,
      apiGenerationEndpoint,
      apiFetchEndpoint,
      setState,
      repeatIndex) async {
    if (repeatIndex > 3) {
      return;
    }

    systemPreferences.activeThreads++;
    final placeholderShot = Shot(index.toString(), '', prompt, nprompt, cfg,
        steps, seed, model, sampler, index);
    imageRepository.addShot(index, placeholderShot);

    final data = <String, dynamic>{
      "options": {"sd_model_checkpoint": allmodels()[model]},
      "original_prompt": prompt,
      "txt2img": {
        "prompt": prompt,
        "negative_prompt": nprompt,
        "steps": steps,
        "width": 640,
        "height": 512,
        "sampler_name": allsamplers()[sampler],
        "cfg_scale": cfg,
        "seed": seed,
        "restore_faces": false,
        "s_tmax": null,
        "s_tmin": 0,
        "styles": null,
        "tiling": false,
        "s_churn": 0,
        "s_noise": 1,
        "subseed": -1,
        "hr_scale": 2,
        "enable_hr": false,
        "batch_size": 1,
        "hr_resize_x": 0,
        "hr_resize_y": 0,
        "hr_upscaler": null,
        "save_images": false,
        "script_args": [],
        "script_name": null,
        "send_images": true,
      },
      apiName: apiKey,
      apiSessionName: apiSession,
      "columnIndex": 0
    };

    final str = jsonEncode(data);
    final Response<dynamic> result;

    try {
      result = await dio.post(apiGenerationEndpoint,
          data: str,
          options: Options(headers: {
            apiName: apiKey,
            apiSessionName: apiSession,
            'accept': 'application/json, text/plain, */*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept-Language': 'it-IT,it;q=0.9',
            'Connection': 'keep-alive',
            'DNT': 1,
            'Host': 'api.curtail.ai',
            'Origin': 'https://www.catbird.ai',
            'Referer': 'https://www.catbird.ai/',
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
    Future.delayed(const Duration(seconds: 30));
    setState(() {});

    int r = 0;
    do {
      Response result2;
      try {
        result2 = await dio.get("$apiFetchEndpoint$job",
            options: Options(headers: {
              'accept': 'application/json, text/plain, */*',
              'Accept-Encoding': 'gzip, deflate, br',
              'Accept-Language': 'it-IT,it;q=0.9',
              'Connection': 'keep-alive',
              'DNT': 1,
              'Host': 'api.curtail.ai',
              'Origin': 'https://www.catbird.ai',
              'Referer': 'https://www.catbird.ai/',
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

      if (resp2.containsKey('jobRec') &&
          resp2['jobRec'].containsKey('response') &&
          resp2['jobRec']['response'] != null &&
          resp2['jobRec']['response'].containsKey('images')) {
        base64image = resp2['jobRec']['response']['images'].first;
      } else {
        if ((resp2['success'] == 'false') || (r > 540)) {
          if (kDebugMode) {
            print('failed job with:\n$resp2');
          }
          eraseOrRedo(earlyShot, setState, apiKey, apiName,
              apiGenerationEndpoint, apiFetchEndpoint, repeatIndex, upscale);
          return;
        }

        r++;
      }
      await Future.delayed(const Duration(seconds: 5));
    } while (base64image.isEmpty);

    final updatedShot = Shot(
        job, '/', prompt, nprompt, cfg, steps, seed, model, sampler, index);

    final blobdata = base64Decode(base64image);
    imageRepository.setBlob(index, blobdata);

    imageRepository.addShot(index, updatedShot);
    systemPreferences.activeThreads--;
    setState(() {});
  }

  void eraseOrRedo(Shot s, setState, apiKey, apiName, apiGenerationEnpoint,
      apiFetchEndpoint, repeatIndex, upscale) {
    imageRepository.addShot(s.index, fakeShot(s.index));
    imageRepository.setBlob(s.index, Uint8List(0));

    setState(() {
      systemPreferences.activeThreads--;
      systemPreferences.errors++;
    });
  }

  @override
  void multiSpan(setState, apiKey, apiName, apiSessionKey, apiSessionName,
      apiGenerationEndpoint, apiFetchEndpoint, prompt, nprompt) async {
    playbackState.setAuto(false);
    imageRepository.clearCache();
    playbackState.setPage(0, () {});
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

    for (int model = 0; model < allmodels().length; model++) {
      if (generationPreferences.selectedModels[model]) {
        for (int sampler = 0; sampler < allsamplers().length; sampler++) {
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
                      model,
                      sampler,
                      cfg,
                      steps,
                      seed,
                      upscale,
                      apiKey,
                      apiName,
                      apiSessionKey,
                      apiSessionName,
                      apiGenerationEndpoint,
                      apiFetchEndpoint,
                      setState,
                      0,
                    ));
                await Future.delayed(const Duration(milliseconds: 500));
              }
            }
          }
        }
      }
    }
  }

  @override
  String get extension => 'png';
}

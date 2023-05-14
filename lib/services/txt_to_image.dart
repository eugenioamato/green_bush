import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:pool/pool.dart';

import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/image_repository.dart';

class TxtToImage {
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final FocusNode focusNode;
  final SystemPreferences systemPreferences;
  final GenerationPreferences generationPreferences;
  late final Pool pool;

  TxtToImage(
    this.playbackState,
    this.imageRepository,
    this.focusNode,
    this.systemPreferences,
    this.generationPreferences,
  ) {
    pool = Pool(systemPreferences.maxThreads,
        timeout: const Duration(seconds: 21));
  }

  final Dio dio = Dio();

  void startGeneration(prompt, nprompt, model, sampler, cfg, steps, seed,
      upscale, apiKey, setState) async {
    if (kDebugMode) {
      print('starting from $prompt');
    }
    systemPreferences.activeThreads++;

    final data = <String, dynamic>{
      "model": generationPreferences.models[model],
      "prompt": prompt,
      "negative_prompt": nprompt,
      "steps": steps,
      "cfg_scale": cfg,
      "sampler": generationPreferences.samplers[sampler],
      "aspect_ratio": "landscape",
      "seed": seed,
      "upscale": upscale,
    };
    final str = jsonEncode(data);

    final result = await dio.post("https://api.prodia.com/v1/job",
        data: str,
        options: Options(headers: {
          "X-Prodia-Key": apiKey,
          'accept': 'application/json',
          'content-type': 'application/json'
        }));

    final resp = jsonDecode(result.toString());
    final String job = resp['job'];
    final earlyShot =
        Shot(job, '', prompt, nprompt, cfg, steps, seed, model, sampler, null);
    imageRepository.src.add(earlyShot);

    String url = '';
    Future.delayed(const Duration(seconds: 10));

    int r = 0;
    do {
      Response result2;
      try {
        result2 = await dio.get("https://api.prodia.com/v1/job/$job",
            options: Options(headers: {
              "X-Prodia-Key": apiKey,
              'accept': 'application/json',
            }));
      } on Exception catch (e) {
        if (kDebugMode) {
          print('error during job creation : $e');
        }
        var index = -1;
        for (int i = 0; i < imageRepository.src.length; i++) {
          if (imageRepository.src[i].id == job) {
            index = i;
            break;
          }
        }

        if (index == -1) return;
        imageRepository.src.removeAt(index);
        systemPreferences.totalrenders--;
        systemPreferences.activeThreads--;
        return;
      }

      final resp2 = jsonDecode(result2.toString());
      if (resp2.containsKey('imageUrl')) {
        url = resp2['imageUrl'];
      } else {
        if ((r > 25) || (resp2['status'] == 'failed')) {
          var index = -1;
          for (int i = 0; i < imageRepository.src.length; i++) {
            if (imageRepository.src[i].id == job) {
              index = i;
              break;
            }
          }
          if (index == -1) return;
          if (playbackState.getPage() >= index) {
            playbackState.setPage(playbackState.getPage() - 1, () {});
          }
          imageRepository.src.removeAt(index);
          systemPreferences.totalrenders--;
          systemPreferences.activeThreads--;
          if (kDebugMode) {
            print('failed job with:\n$resp2');
          }
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
        if (kDebugMode) {
          print('retry d:$job r=$r');
        }
        r++;
      }
    } while (url.isEmpty);

    final updatedShot =
        Shot(job, url, prompt, nprompt, cfg, steps, seed, model, sampler, null);
    var index = -1;
    for (int i = 0; i < imageRepository.src.length; i++) {
      if (imageRepository.src[i].id == job) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      if (kDebugMode) {
        print('Orphaned job $job');
      }
      systemPreferences.activeThreads--;
      return;
    }
    imageRepository.src[index] = updatedShot;
    final page = playbackState.getPage();
    if (url.isNotEmpty) {
      if ((index - page <= systemPreferences.getRange()) &&
          (index - page >= 0)) {
        if (!imageRepository.getPrecaching().contains(job)) {
          imageRepository.poolprecache(updatedShot, playbackState);
        }
      }
      systemPreferences.activeThreads--;
    }
    setState(() {});
  }

  void multiSpan(setState, apiKey, prompt, nprompt) {
    playbackState.setAuto(false);
    imageRepository.clearCache();
    imageRepository.src.clear();

    playbackState.setPage(0, () {});
    playbackState.setLoading(0.0);
    focusNode.requestFocus();
    systemPreferences.totalrenders = 0;
    setState(() {
      imageRepository.src.clear();
    });
    playbackState.setPage(0, () {});

    var seed = -1;
    if (!generationPreferences.getRandomSeed()) {
      if (seed == -1) {
        seed = Random().nextInt(199999999);
      }
    }

    final upscale = generationPreferences.getUpscale();

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
                pool.withResource(() => startGeneration(prompt, nprompt, method,
                    sampler, cfg, steps, seed, upscale, apiKey, setState));
                Future.delayed(const Duration(milliseconds: 250));
              }
            }
          }
        }
      }
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/ui/actions_widget.dart';
import 'package:green_bush/ui/carousel_widget.dart';
import 'package:green_bush/ui/progress_slider.dart';
import 'package:green_bush/ui/settings_widget.dart';
import 'package:pool/pool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import '../services/image_repository.dart';
import '../services/playback_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.title});
  final String title;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController controller = TextEditingController()
    ..text = "Green bush, awesome, ";
  TextEditingController controller2 = TextEditingController()
    ..text = "cartoon, blur";
  CarouselController carouselController = CarouselController();

  GenerationPreferences generationPreferences = GenerationPreferences();
  SystemPreferences systemPreferences = SystemPreferences();
  late ImageRepository imageRepository;
  late PlaybackState playbackState;

  var _pressed = false;
  void manageKeyEvent(KeyEvent event) {
    if (event.logicalKey.keyId == 32) {
      playbackState.setAuto(false);
      Shot shot = imageRepository.src[playbackState.getPage()];
      launchUrl(Uri.parse(shot.url), mode: LaunchMode.externalApplication);
    } else if (event.logicalKey.keyId == 115) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.nextPage(duration: const Duration(milliseconds: 40));
        _pressed = true;
      }
    } else if (event.logicalKey.keyId == 119) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.previousPage(
            duration: const Duration(milliseconds: 40));
        _pressed = true;
      }
    } else if (event.logicalKey.keyId == 100) {
      if (_pressed) {
        _pressed = false;
      } else {
        setState(() {
          playbackState.setAuto(!playbackState.getAuto());
        });
        _pressed = true;
      }
    } else if (event.logicalKey.keyId == 97) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.jumpToPage(0);
        _pressed = true;
      }
    }
  }

  late final String apiKey;

  @override
  void initState() {
    apiKey = const String.fromEnvironment('API_KEY');
    pool = Pool(systemPreferences.maxThreads,
        timeout: const Duration(seconds: 21));
    imageRepository = ImageRepository(systemPreferences);
    playbackState = PlaybackState(imageRepository, systemPreferences);
    if (kDebugMode) {
      print('API_KEY IS $apiKey');
    }

    if (Platform.isWindows || Platform.isMacOS) {
      systemPreferences.setRange(50);
      systemPreferences.maxThreads = 50;
    }
    super.initState();
  }

  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    imageRepository.clearCache();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: OrientationBuilder(builder: (context, orientation) {
          if (kDebugMode) {
            print('rebuilding dash');
          }
          final total = (imageRepository.src.length) < 2
              ? 1
              : (imageRepository.src.length) - 1;
          final totalThreads = systemPreferences.getActiveThreads();
          if (orientation == Orientation.landscape) {
            return Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 15,
                  child: Stack(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: CarouselWidget(
                          playbackState: playbackState,
                          src: imageRepository.src,
                          precache: imageRepository.poolprecache,
                          getPrecaching: imageRepository.getPrecaching,
                          focusNode: focusNode,
                          carouselController: carouselController,
                          refresh: refresh,
                          manageKeyEvent: manageKeyEvent,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.95, -0.95),
                        child: Icon((totalThreads >
                                (systemPreferences.maxThreads * 0.7))
                            ? Icons.hourglass_full
                            : (totalThreads >
                                    (systemPreferences.maxThreads * 0.5))
                                ? Icons.hourglass_bottom
                                : (totalThreads >
                                        (systemPreferences.maxThreads * 0.1))
                                    ? Icons.hourglass_empty
                                    : Icons.check),
                        //color: (Colors.green),
                      ),
                      Align(
                          alignment: const Alignment(0.95, -0.85),
                          child: Text(
                              '$totalThreads/${systemPreferences.maxThreads}/${systemPreferences.maxDownloads}')
                          //color: (Colors.green),
                          ),
                      ((imageRepository.src.isNotEmpty) &&
                              (playbackState.getPage() <
                                  imageRepository.src.length))
                          ? Align(
                              alignment: const Alignment(0, 0.90),
                              child: Text(
                                '${createLabel(imageRepository.src[playbackState.getPage()])}',
                                textAlign: TextAlign.center,
                              )
                              //color: (Colors.green),
                              )
                          : Container(),
                      Align(
                        alignment: const Alignment(-0.95, 0.95),
                        child: KeyboardListener(
                          onKeyEvent: manageKeyEvent,
                          focusNode: focusNode,
                          child: IconButton(
                              iconSize: 32,
                              onPressed: () {
                                setState(() {
                                  playbackState
                                      .setAuto(!playbackState.getAuto());
                                });
                              },
                              icon: Icon(
                                (playbackState.getAuto()
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle),
                                //color: (Colors.green),
                                color: Colors.green,
                              )),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.95, -0.95),
                        child: IntrinsicWidth(
                          child: ExpansionTile(
                            iconColor: Colors.transparent,
                            title: Align(
                              alignment: const Alignment(-0.95, -0.95),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                            ),
                            children: [
                              IntrinsicHeight(
                                child: Card(
                                  color: Colors.black,
                                  child: SettingsWidget(
                                    systemPreferences: systemPreferences,
                                    showActions: true,
                                    orientation: orientation,
                                    refreshCallback: () {
                                      setState(() {});
                                    },
                                    generationPreferences:
                                        generationPreferences,
                                    controller: controller,
                                    controller2: controller2,
                                    multispanCallback: _multiSpan,
                                    playbackState: playbackState,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.75),
                        child: Text(
                          '${playbackState.getPage() + 1} / ${imageRepository.src.length} / ${systemPreferences.totalrenders}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: KeyboardListener(
                    onKeyEvent: manageKeyEvent,
                    focusNode: focusNode,
                    child: ProgressSlider(
                      playbackState: playbackState,
                      carouselController: carouselController,
                      total: total,
                      refresh: refresh,
                    ),
                  ),
                ),
              ],
            );
          } else {
            //portrait
            return Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                    flex: 6,
                    child: ActionsWidget(
                      systemPreferences: systemPreferences,
                      generationPreferences: generationPreferences,
                      controller2: controller2,
                      controller: controller,
                      orientation: orientation,
                      multispanCallback: _multiSpan,
                      refreshCallback: () {
                        setState(() {});
                      },
                      playbackState: playbackState,
                    )),
                Flexible(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '${playbackState.getPage()} / ${imageRepository.src.length} / ${systemPreferences.totalrenders}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
                Flexible(
                  child: Slider(
                    divisions: total,
                    thumbColor: Colors.green,
                    inactiveColor: Colors.yellow.withOpacity(0.2),
                    activeColor: Colors.yellow.withOpacity(0.2),
                    value: playbackState.getPage().toDouble() / total,
                    onChanged: (double value) {
                      carouselController.jumpToPage((value * total).toInt());
                    },
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: CarouselWidget(
                    src: imageRepository.src,
                    playbackState: playbackState,
                    precache: imageRepository.precache,
                    getPrecaching: imageRepository.getPrecaching,
                    focusNode: focusNode,
                    carouselController: carouselController,
                    refresh: refresh,
                    manageKeyEvent: manageKeyEvent,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SettingsWidget(
                    systemPreferences: systemPreferences,
                    orientation: orientation,
                    showActions: false,
                    refreshCallback: () {
                      setState(() {});
                    },
                    controller: controller,
                    controller2: controller2,
                    multispanCallback: _multiSpan,
                    generationPreferences: generationPreferences,
                    playbackState: playbackState,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Dio dio = Dio();

  void _startGeneration(prompt, nprompt, method, sampler, cfg, steps, seed,
      upscale, apiKey) async {
    if (kDebugMode) {
      print('starting from ${controller.text}');
    }
    setState(() {
      systemPreferences.activeThreads++;
    });

    final data = <String, dynamic>{
      "model": generationPreferences.models[method],
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
        Shot(job, '', prompt, nprompt, cfg, steps, seed, method, sampler, null);
    imageRepository.src.add(earlyShot);
    setState(() {});

    String url = '';
    Future.delayed(const Duration(seconds: 5));

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
        setState(() {});
        return;
      }

      final resp2 = jsonDecode(result2.toString());
      if (resp2.containsKey('imageUrl')) {
        url = resp2['imageUrl'];
      } else {
        if ((r > 3) || (resp2['status'] == 'failed')) {
          var index = -1;
          for (int i = 0; i < imageRepository.src.length; i++) {
            if (imageRepository.src[i].id == job) {
              index = i;
              break;
            }
          }
          if (index == -1) return;
          if (playbackState.getPage() >= index) {
            carouselController.previousPage();
          }
          imageRepository.src.removeAt(index);
          systemPreferences.totalrenders--;
          systemPreferences.activeThreads--;
          if (kDebugMode) {
            print('failed job with:\n$resp2');
          }
          setState(() {});
          return;
        }
        await Future.delayed(const Duration(seconds: 5));
        if (kDebugMode) {
          print('retry d:$job r=$r');
        }
        r++;
      }
    } while (url.isEmpty);

    final updatedShot = Shot(
        job, url, prompt, nprompt, cfg, steps, seed, method, sampler, null);
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
      setState(() {});
    }
  }

  late final Pool pool;

  void _multiSpan() {
    playbackState.setAuto(false);
    imageRepository.clearCache();
    imageRepository.src.clear();
    carouselController.jumpToPage(0);
    playbackState.setLoading(0.0);
    focusNode.requestFocus();
    systemPreferences.totalrenders = 0;
    setState(() {
      imageRepository.src.clear();
    });
    carouselController.jumpToPage(0);

    var prompt = controller.text;
    var nprompt = controller2.text;
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
                pool.withResource(() => _startGeneration(prompt, nprompt,
                    method, sampler, cfg, steps, seed, upscale, apiKey));
                Future.delayed(const Duration(milliseconds: 50));
              }
            }
          }
        }
      }
    }
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  createLabel(Shot s) {
    return '${s.seed} ${generationPreferences.models[s.method]} ${generationPreferences.samplers[s.sampler]} ${s.cfg} ${s.steps}';
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/ui/actions_widget.dart';
import 'package:green_bush/ui/carousel_widget.dart';
import 'package:green_bush/ui/settings_widget.dart';
import 'package:pool/pool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.title});
  final String title;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int maxThreads = 50;
  TextEditingController controller = TextEditingController()
    ..text = "young Lindsay And Sidney Greenbush";
  TextEditingController controller2 = TextEditingController()
    ..text = "cartoon, blur";
  CarouselController carouselController = CarouselController();
  int activeThreads = 0;
  int getActiveThreads() => activeThreads;
  var _pressed = false;

  void manageKeyEvent(KeyEvent event) {
    if (event.logicalKey.keyId == 32) {
      if (_pressed) {
        _pressed = false;
      } else {
        setAuto(false);
        Shot shot = src[getPage()];
        launchUrl(Uri.parse(shot.url), mode: LaunchMode.externalApplication);
        _pressed = true;
      }
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
    }
  }

  int maxDownloads = 25;

  bool _randomSeed = false;
  bool getRandomSeed() => _randomSeed;
  void setRandomSeed(v) => setState(() {
        _randomSeed = v;
      });

  bool _auto = false;
  bool getAuto() => _auto;
  void setAuto(v) => _auto = v;

  bool _waiting = false;
  bool getWaiting() => _waiting;
  void setWaiting(v) => _waiting = v;

  double _loading = 0.0;
  double getLoading() => _loading;
  void setLoading(double rate) => _loading = rate;
  late final String apiKey;
  @override
  void initState() {
    apiKey = const String.fromEnvironment('API_KEY');
    if (kDebugMode) {
      print('API_KEY IS $apiKey');
    }
    pool = Pool(maxThreads, timeout: const Duration(seconds: 21));
    pool2 = Pool(maxDownloads, timeout: const Duration(seconds: 16));
    if (Platform.isWindows || Platform.isMacOS) {
      range = 50;
      maxThreads = 50;
    }
    super.initState();
  }

  int totalrenders = 0;
  int range = 30;
  int _page = 0;
  void setPage(page) {
    var len = src.length;
    if (len == 0) {
      _page = 0;
      return;
    }

    for (int i = 0; i < len; i++) {
      int upLimit = page + range;
      if (upLimit > len) {
        upLimit = len;
      }
      if (i < upLimit && i > (page - 10)) {
        pool2.withResource(() => precache(src[i]));
      } else {
        removeFromCache(src[(i)]);
      }
    }

    updateSecondarySlider();
    if (src[page].image == null) {
      if (getAuto()) {
        setWaiting(true);
        setAuto(false);
      }
    }
    setState(() {
      _page = page;
    });
  }

  int getPage() => _page;

  double cfgSliderValue = 7;
  void setCfgSliderValue(v) => cfgSliderValue = v;

  double stepSliderValue = 35;
  void setStepSliderValue(v) => stepSliderValue = v;

  double cfgSliderEValue = 7;
  void setCfgSliderEValue(v) => cfgSliderEValue = v;

  double stepSliderEValue = 35;
  void setStepSliderEValue(v) => stepSliderEValue = v;

  FocusNode focusNode = FocusNode();
  List<Shot> src = [];

  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    for (var s in src) {
      if (s.url.isNotEmpty) {
        removeFromCache(s);
      }
      src.clear();
    }
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
          final total = (src.length) < 2 ? 1 : (src.length) - 1;
          final totalThreads = getActiveThreads();
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
                          src: src,
                          setPage: setPage,
                          getPage: getPage,
                          getAuto: getAuto,
                          setAuto: setAuto,
                          precache: poolprecache,
                          getPrecaching: getPrecaching,
                          focusNode: focusNode,
                          carouselController: carouselController,
                          refresh: refresh,
                          setWaiting: setWaiting,
                          getWaiting: getWaiting,
                          manageKeyEvent: manageKeyEvent,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.95, -0.95),
                        child: Icon((totalThreads > (maxThreads * 0.7))
                            ? Icons.hourglass_full
                            : (totalThreads > (maxThreads * 0.5))
                                ? Icons.hourglass_bottom
                                : (totalThreads > (maxThreads * 0.1))
                                    ? Icons.hourglass_empty
                                    : Icons.check),
                        //color: (Colors.green),
                      ),
                      Align(
                          alignment: const Alignment(0.95, -0.85),
                          child: Text('$totalThreads/$maxThreads/$maxDownloads')
                          //color: (Colors.green),
                          ),
                      Align(
                        alignment: const Alignment(-0.95, 0.95),
                        child: KeyboardListener(
                          onKeyEvent: manageKeyEvent,
                          focusNode: focusNode,
                          child: IconButton(
                              iconSize: 32,
                              onPressed: () {
                                setState(() {
                                  if (getAuto()) {
                                    setWaiting(false);
                                  }
                                  setAuto(!getAuto());
                                });
                              },
                              icon: Icon(
                                (getAuto()
                                    ? Icons.play_circle
                                    : Icons.play_circle_outline),
                                //color: (Colors.green),
                                color: getWaiting() ? Colors.red : Colors.green,
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
                                    showActions: true,
                                    orientation: orientation,
                                    getActiveThreads: getActiveThreads,
                                    refreshCallback: () {
                                      setState(() {});
                                    },
                                    getRandomSeed: getRandomSeed,
                                    setRandomSeed: setRandomSeed,
                                    controller: controller,
                                    controller2: controller2,
                                    models: models,
                                    toggleModel: toggleModel,
                                    isModelEnabled: isModelEnabled,
                                    cfgSliderEValue: cfgSliderEValue,
                                    setCfgSliderEValue: setCfgSliderEValue,
                                    cfgSliderValue: cfgSliderValue,
                                    setCfgSliderValue: setCfgSliderValue,
                                    stepSliderEValue: stepSliderEValue,
                                    setStepSliderValue: setStepSliderValue,
                                    stepSliderValue: stepSliderValue,
                                    setStepSliderEValue: setStepSliderEValue,
                                    setAuto: setAuto,
                                    getAuto: getAuto,
                                    multispanCallback: _multiSpan,
                                    maxThreads: maxThreads,
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
                          '${getPage() + 1} / ${src.length} / $totalrenders',
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
                    child: Slider(
                      secondaryTrackValue: getLoading(),
                      divisions: total,
                      thumbColor: Colors.green,
                      inactiveColor: Colors.yellow.withOpacity(0.2),
                      activeColor: Colors.yellow.withOpacity(0.2),
                      value: getPage().toDouble() / total,
                      onChanged: (double value) {
                        carouselController.jumpToPage((value * total).toInt());
                      },
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
                      controller2: controller2,
                      controller: controller,
                      maxThreads: maxThreads,
                      orientation: orientation,
                      multispanCallback: _multiSpan,
                      getActiveThreads: getActiveThreads,
                      refreshCallback: () {
                        setState(() {});
                      },
                      getRandomSeed: getRandomSeed,
                      setRandomSeed: setRandomSeed,
                      setAuto: setAuto,
                      getAuto: getAuto,
                      isModelEnabled: isModelEnabled,
                      toggleModel: toggleModel,
                      models: models,
                    )),
                Flexible(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '${getPage()} / ${src.length} / $totalrenders',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
                Flexible(
                  child: Slider(
                    divisions: total,
                    thumbColor: Colors.green,
                    inactiveColor: Colors.yellow.withOpacity(0.2),
                    activeColor: Colors.yellow.withOpacity(0.2),
                    value: getPage().toDouble() / total,
                    onChanged: (double value) {
                      carouselController.jumpToPage((value * total).toInt());
                    },
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: CarouselWidget(
                    src: src,
                    getAuto: getAuto,
                    setPage: setPage,
                    getPage: getPage,
                    setAuto: setAuto,
                    precache: precache,
                    getPrecaching: getPrecaching,
                    focusNode: focusNode,
                    carouselController: carouselController,
                    getWaiting: getWaiting,
                    setWaiting: setWaiting,
                    refresh: refresh,
                    manageKeyEvent: manageKeyEvent,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SettingsWidget(
                    orientation: orientation,
                    showActions: false,
                    refreshCallback: () {
                      setState(() {});
                    },
                    getRandomSeed: getRandomSeed,
                    setRandomSeed: setRandomSeed,
                    getActiveThreads: getActiveThreads,
                    controller: controller,
                    controller2: controller2,
                    models: models,
                    isModelEnabled: isModelEnabled,
                    toggleModel: toggleModel,
                    cfgSliderEValue: cfgSliderEValue,
                    setCfgSliderEValue: setCfgSliderEValue,
                    cfgSliderValue: cfgSliderValue,
                    setCfgSliderValue: setCfgSliderValue,
                    stepSliderEValue: stepSliderEValue,
                    setStepSliderValue: setStepSliderValue,
                    stepSliderValue: stepSliderValue,
                    setStepSliderEValue: setStepSliderEValue,
                    setAuto: setAuto,
                    getAuto: getAuto,
                    multispanCallback: _multiSpan,
                    maxThreads: maxThreads,
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

  void _startGeneration(
      prompt, nprompt, method, sampler, cfg, steps, seed, apiKey) async {
    if (kDebugMode) {
      print('starting from ${controller.text}');
    }
    setState(() {
      activeThreads++;
    });

    final data = <String, dynamic>{
      "model": models[method],
      "prompt": prompt,
      "negative_prompt": nprompt,
      "steps": steps,
      "cfg_scale": cfg,
      "sampler": samplers[sampler],
      "aspect_ratio": "landscape",
      "seed": seed,
      "upscale": false,
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
    src.add(earlyShot);
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
        for (int i = 0; i < src.length; i++) {
          if (src[i].id == job) {
            index = i;
            break;
          }
        }

        if (index == -1) return;
        src.removeAt(index);
        totalrenders--;
        activeThreads--;
        setState(() {});
        return;
      }

      final resp2 = jsonDecode(result2.toString());
      if (resp2.containsKey('imageUrl')) {
        url = resp2['imageUrl'];
      } else {
        await Future.delayed(const Duration(seconds: 5));
        if (kDebugMode) {
          print('retry d:$job r=$r');
        }
        if (r > 10) {
          var index = -1;
          for (int i = 0; i < src.length; i++) {
            if (src[i].id == job) {
              index = i;
              break;
            }
          }
          if (index == -1) return;
          src.removeAt(index);
          totalrenders--;
          activeThreads--;
          setState(() {});
          return;
        }
        r++;
      }
    } while (url.isEmpty);

    final updatedShot = Shot(
        job, url, prompt, nprompt, cfg, steps, seed, method, sampler, null);
    var index = -1;
    for (int i = 0; i < src.length; i++) {
      if (src[i].id == job) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      if (kDebugMode) {
        print('Orphaned job $job');
      }
      activeThreads--;
      return;
    }
    src[index] = updatedShot;
    final page = getPage();
    if (url.isNotEmpty) {
      if ((index - page <= range) && (index - page > -5)) {
        if (!getPrecaching().contains(job)) {
          pool2.withResource(() => precache(updatedShot));
        }
      }
      activeThreads--;
      setState(() {});
    }
  }

  void removeFromCache(Shot s) {
    if (s.image != null) {
      s.image?.image.evict();
      s.image = null;
    }
  }

  Set<String> precaching = {};
  Set<String> getPrecaching() => precaching;

  void poolprecache(Shot s) {
    pool2.withResource(() => precache(s));
  }

  void precache(Shot s) {
    if (s.image != null) return;
    final url = s.url;
    if (url.isEmpty) return;
    getPrecaching().add(s.id);
    if (kDebugMode) {
      print('starting precache ${s.id}');
    }
    activeThreads++;
    late final Image image;
    try {
      image = Image(
        image: Image.network(
          url,
        ).image,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error creating image $e');
      }
      activeThreads--;
      return;
    }

    try {
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((_, __) {
            //final bytes = PaintingBinding.instance.imageCache.currentSizeBytes;
            //final maxbytes = PaintingBinding.instance.imageCache.maximumSizeBytes;
            //if (kDebugMode) {
            //  print(':: $bytes / $maxbytes');
            //}
            getPrecaching().remove(s.id);
            if (kDebugMode) {
              print('ending    precache ${s.id} ${getPrecaching()} }');
            }
            int index = -1;
            for (int i = 0; i < src.length; i++) {
              if (src[i].id == s.id) {
                index = i;
                break;
              }
            }
            updateSecondarySlider();
            if (getPage() == index) {
              if (mounted) {
                setState(() {});
              }
            }
          }, onError: (e, stack) {
            if (kDebugMode) {
              print('error on listener $e $stack');
            }
          }));
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error resolving image $e');
      }
      getPrecaching().remove(s.id);
      activeThreads--;
      return;
    }
    activeThreads--;
    s.image = image;
  }

  final models = [
    "elldreths-vivid-mix.safetensors [342d9d26]", //#shiny
    "deliberate_v2.safetensors [10ec4b29]", // #realistic #errorprone
    "dreamshaper_5BakedVae.safetensors [a3fbf318]", // #art b&w
    "revAnimated_v122.safetensors [3f4fefd9]", // #plastic
    "lyriel_v15.safetensors [65d547c5]", // #jesus
  ];

  var selectedModels = [true, false, false, true, true];

  bool isModelEnabled(n) {
    if ((n < 0) || (n >= models.length)) {
      return false;
    } else {
      return selectedModels[n];
    }
  }

  void toggleModel(n) {
    if ((n < 0) || (n >= models.length)) return;
    selectedModels[n] = !selectedModels[n];
  }

  final samplers = [
    "DPM++ 2M Karras",
    "Euler a",
    "Heun",
  ];
  late final Pool pool;
  late final Pool pool2;

  void _multiSpan() {
    setAuto(false);
    setWaiting(false);
    carouselController.jumpToPage(0);
    focusNode.requestFocus();
    for (var s in src) {
      removeFromCache(s);
    }
    totalrenders = 0;
    setState(() {
      src.clear();
    });
    carouselController.jumpToPage(0);

    var prompt = controller.text;
    var nprompt = controller2.text;
    var seed = -1;
    if (!getRandomSeed()) {
      if (seed == -1) {
        seed = Random().nextInt(199999999);
      }
    }
    for (int method = 0; method < selectedModels.length; method++) {
      if (selectedModels[method]) {
        for (int sampler = 0; sampler < samplers.length; sampler++) {
          for (int cfg = cfgSliderValue.toInt();
              cfg < cfgSliderEValue + 1;
              cfg++) {
            for (int steps = stepSliderValue.toInt();
                steps < stepSliderEValue + 1;
                steps += 1) {
              totalrenders++;
              pool.withResource(() => _startGeneration(
                  prompt, nprompt, method, sampler, cfg, steps, seed, apiKey));
              Future.delayed(const Duration(milliseconds: 50));
            }
          }
        }
      }
    }
  }

  void updateSecondarySlider() {
    int k = getPage();
    for (int i = getPage(); i < src.length; i++) {
      if (src[i].image == null) break;
      k++;
    }
    setLoading(k / src.length);
  }

  refresh() {
    setState(() {});
  }
}

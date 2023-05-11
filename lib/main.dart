import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gif_view/gif_view.dart';
import 'package:pool/pool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenBush',
      theme: _buildShrineTheme(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'GreenBush'),
    );
  }

  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: bushColor100,
      scaffoldBackgroundColor: shrineBackgroundWhite,
      cardColor: shrineBackgroundWhite,
      primaryIconTheme: _customIconTheme(base.iconTheme),
      textTheme: _buildShrineTextTheme(base.textTheme),
      primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
      iconTheme: _customIconTheme(base.iconTheme),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return bushColor400;
          }
          return Colors.green;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return bushColor400;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return bushColor400;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return bushColor400;
          }
          return null;
        }),
      ),
      colorScheme: _shrineColorScheme
          .copyWith(error: shrineErrorRed)
          .copyWith(secondary: shrineBrown900),
    );
  }

  IconThemeData _customIconTheme(IconThemeData original) {
    return original.copyWith(color: shrineBrown900);
  }

  TextTheme _buildShrineTextTheme(TextTheme base) {
    return base.apply(
      fontFamily: 'PressStart2P',
      displayColor: shrineBrown900,
      bodyColor: shrineBrown900,
    );
  }
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: bushColor100,
  secondary: bushColor50,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

const Color bushColor50 = Colors.limeAccent;
const Color bushColor100 = Colors.lightGreen;
const Color bushColor300 = Colors.lightGreen;
const Color bushColor400 = Colors.lightGreen;
const Color shrineBrown900 = Colors.green;
const Color shrineBrown600 = Colors.greenAccent;
const Color shrineErrorRed = Color(0xFFC5032B);
const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;
int maxThreads = 50;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController()
    ..text = "young Lindsay And Sidney Greenbush";
  TextEditingController controller2 = TextEditingController()
    ..text = "cartoon, blur";
  CarouselController carouselController = CarouselController();
  int activeThreads = 0;
  int getActiveThreads() => activeThreads;

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
      for (int ranger = page; ranger < upLimit; ranger++) {
        pool2.withResource(() => precache(src[ranger]));
      }
      if (totalrenders > range && (page - range >= 0)) {
        removeFromCache(src[(page - range)]);
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
      "model": methods[method],
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

  final methods = [
    "elldreths-vivid-mix.safetensors [342d9d26]",
    'lyriel_v15.safetensors [65d547c5]',
    "revAnimated_v122.safetensors [3f4fefd9]",
  ];

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
    for (int method = 0; method < methods.length; method++) {
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

class SettingsWidget extends StatefulWidget {
  final bool showActions;
  final Orientation orientation;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function getActiveThreads;
  final Function refreshCallback;
  final Function multispanCallback;
  final double cfgSliderValue;
  final Function setCfgSliderValue;
  final double cfgSliderEValue;
  final Function setCfgSliderEValue;
  final double stepSliderValue;
  final Function setStepSliderValue;
  final double stepSliderEValue;
  final Function setStepSliderEValue;
  final Function setAuto;
  final Function getAuto;
  final Function getRandomSeed;
  final Function setRandomSeed;

  const SettingsWidget({
    Key? key,
    required this.refreshCallback,
    required this.cfgSliderValue,
    required this.cfgSliderEValue,
    required this.stepSliderValue,
    required this.stepSliderEValue,
    required this.multispanCallback,
    required this.setCfgSliderValue,
    required this.setCfgSliderEValue,
    required this.setStepSliderValue,
    required this.setStepSliderEValue,
    required this.setAuto,
    required this.getAuto,
    required this.controller,
    required this.controller2,
    required this.showActions,
    required this.orientation,
    required this.getActiveThreads,
    required this.getRandomSeed,
    required this.setRandomSeed,
  }) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.black,
                      child: Slider.adaptive(
                          thumbColor: Colors.green,
                          inactiveColor: Colors.yellow.withOpacity(0.2),
                          activeColor: Colors.yellow.withOpacity(0.2),
                          value: widget.cfgSliderValue,
                          min: 1,
                          max: widget.cfgSliderEValue,
                          onChanged: (v) {
                            widget.setCfgSliderValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.black,
                      child: Slider.adaptive(
                          thumbColor: Colors.green,
                          inactiveColor: Colors.yellow.withOpacity(0.2),
                          activeColor: Colors.yellow.withOpacity(0.2),
                          value: widget.stepSliderValue,
                          min: 1,
                          max: widget.stepSliderEValue,
                          onChanged: (v) {
                            widget.setStepSliderValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    'CFG :${widget.cfgSliderValue.toInt()} - ${widget.cfgSliderEValue.toInt()}',
                  )),
                ],
              )),
          Flexible(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.black,
                      child: Slider.adaptive(
                          thumbColor: Colors.green,
                          inactiveColor: Colors.yellow.withOpacity(0.2),
                          activeColor: Colors.yellow.withOpacity(0.2),
                          value: widget.cfgSliderEValue,
                          min: widget.cfgSliderValue,
                          max: 20,
                          onChanged: (v) {
                            widget.setCfgSliderEValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.black,
                      child: Slider.adaptive(
                          thumbColor: Colors.green,
                          inactiveColor: Colors.yellow.withOpacity(0.2),
                          activeColor: Colors.yellow.withOpacity(0.2),
                          value: widget.stepSliderEValue,
                          min: widget.stepSliderValue,
                          max: 50,
                          onChanged: (v) {
                            widget.setStepSliderEValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    'STEP:${widget.stepSliderValue.toInt()} - ${widget.stepSliderEValue.toInt()}',
                  )),
                ],
              )),
          if (widget.showActions)
            Flexible(
                flex: 1,
                child: ActionsWidget(
                  controller2: widget.controller2,
                  controller: widget.controller,
                  orientation: widget.orientation,
                  multispanCallback: widget.multispanCallback,
                  refreshCallback: widget.refreshCallback,
                  setAuto: widget.setAuto,
                  getAuto: widget.getAuto,
                  getActiveThreads: widget.getActiveThreads,
                  getRandomSeed: widget.getRandomSeed,
                  setRandomSeed: widget.setRandomSeed,
                )),
        ],
      ),
    );
  }
}

class ActionsWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function refreshCallback;
  final Function multispanCallback;
  final Function setAuto;
  final Function getAuto;
  final Function getActiveThreads;
  final Orientation orientation;
  final Function getRandomSeed;
  final Function setRandomSeed;
  const ActionsWidget(
      {Key? key,
      required this.controller,
      required this.controller2,
      required this.refreshCallback,
      required this.multispanCallback,
      required this.setAuto,
      required this.getAuto,
      required this.orientation,
      required this.getActiveThreads,
      required this.getRandomSeed,
      required this.setRandomSeed})
      : super(key: key);

  @override
  State<ActionsWidget> createState() => _ActionsWidgetState();
}

class _ActionsWidgetState extends State<ActionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.end,
      direction: Axis.vertical,
      children: [
        Expanded(
            flex: 3,
            child: PromptsWidget(
              controller: widget.controller,
              controller2: widget.controller2,
              orientation: widget.orientation,
            )),
        Flexible(
          flex: 1,
          child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            widget.setAuto(!widget.getAuto());
                          });
                          widget.refreshCallback();
                        },
                        icon: Icon(
                          (widget.getAuto()
                              ? Icons.play_circle
                              : Icons.play_circle_outline),
                          color: (Colors.green),
                        ))),
                Expanded(
                  child: IconButton(
                      onPressed: () => widget.multispanCallback(),
                      icon: Icon(
                        Icons.generating_tokens,
                        color: (widget.getActiveThreads() == 0
                            ? Colors.green
                            : widget.getActiveThreads() > maxThreads * 0.5
                                ? Colors.red
                                : Colors.orange),
                      )),
                ),
                Expanded(
                    child: Checkbox(
                  value: widget.getRandomSeed(),
                  onChanged: (v) => widget.setRandomSeed(v),
                )),
              ]),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatefulWidget {
  final List src;
  final FocusNode focusNode;
  final CarouselController carouselController;
  final Function setPage;
  final Function getPage;
  final Function getAuto;
  final Function precache;
  final Function getPrecaching;

  final Function setWaiting;
  final Function getWaiting;
  final Function refresh;

  final Function setAuto;
  const CarouselWidget(
      {Key? key,
      required this.src,
      required this.focusNode,
      required this.carouselController,
      required this.getAuto,
      required this.setPage,
      required this.getPage,
      required this.setAuto,
      required this.precache,
      required this.getPrecaching,
      required this.setWaiting,
      required this.getWaiting,
      required this.refresh})
      : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event.logicalKey.keyId == 32) {
        } else if (event.logicalKey.keyId == 115) {
          if (_pressed) {
            _pressed = false;
          } else {
            widget.carouselController
                .nextPage(duration: const Duration(milliseconds: 40));
            _pressed = true;
          }
        } else if (event.logicalKey.keyId == 119) {
          if (_pressed) {
            _pressed = false;
          } else {
            widget.carouselController
                .previousPage(duration: const Duration(milliseconds: 40));
            _pressed = true;
          }
        }
      },
      child: IntrinsicHeight(
        child: CarouselSlider(
          items: widget.src
              .map((e) => Thumb(
                    shot: e,
                    setAuto: widget.setAuto,
                    precache: widget.precache,
                    getPrecaching: widget.getPrecaching,
                    getWaiting: widget.getWaiting,
                    refresh: widget.refresh,
                    setWaiting: widget.setWaiting,
                  ))
              .toList(),
          carouselController: widget.carouselController,
          options: CarouselOptions(
            initialPage: widget.getPage(),
            onPageChanged: (index, reason) {
              widget.setPage(index);
            },
            pauseAutoPlayOnTouch: true,
            autoPlay: widget.getAuto(),
            autoPlayAnimationDuration: const Duration(milliseconds: 1),
            scrollDirection: Axis.vertical,
            enableInfiniteScroll: false,
            autoPlayInterval: const Duration(milliseconds: 800),
            viewportFraction: 1.0,
          ),
        ),
      ),
    );
  }
}

class PromptsWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final Orientation orientation;
  const PromptsWidget(
      {Key? key,
      required this.controller,
      required this.controller2,
      required this.orientation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Card(
            color: Colors.black,
            child: TextField(
              controller: controller,
              maxLines: orientation == Orientation.landscape ? 1 : 4,
              showCursor: true,
              //cursorColor: Colors.yellow,
              cursorHeight: 10,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 10),
            ),
          ),
        ),
        Expanded(
            child: Card(
          color: Colors.black,
          child: TextField(
            controller: controller2,
            maxLines: orientation == Orientation.landscape ? 1 : 4,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10),
          ),
        )),
      ],
    );
  }
}

class Shot implements Comparable<Shot> {
  Shot(this.id, this.url, this.prompt, this.nprompt, this.cfg, this.steps,
      this.seed, this.method, this.sampler, this.image);

  String get label => '$seed $method > $sampler $cfg $steps';
  final String id;
  final String prompt;
  final String nprompt;
  final String url;
  final int cfg;
  final int steps;
  final int seed;
  final int method;
  final int sampler;
  Image? image;

  @override
  int compareTo(Shot other) {
    if (prompt == other.prompt) {
      if (nprompt == other.nprompt) {
        if (seed == other.seed) {
          if (method == other.method) {
            if (sampler == other.sampler) {
              if (cfg == other.cfg) {
                if (steps == other.steps) {
                  return id.compareTo(other.id);
                } else {
                  return steps.compareTo(other.steps);
                }
              } else {
                return cfg.compareTo(other.cfg);
              }
            } else {
              return sampler.compareTo(other.sampler);
            }
          } else {
            return method.compareTo(other.method);
          }
        } else {
          return seed.compareTo(other.seed);
        }
      } else {
        return nprompt.compareTo(nprompt);
      }
    } else {
      return prompt.compareTo(other.prompt);
    }
  }
}

class Thumb extends StatefulWidget {
  final Shot shot;
  final Function setAuto;
  final Function precache;
  final Function getPrecaching;
  final Function setWaiting;
  final Function getWaiting;
  final Function refresh;

  const Thumb({
    Key? key,
    required this.shot,
    required this.setAuto,
    required this.precache,
    required this.getPrecaching,
    required this.setWaiting,
    required this.getWaiting,
    required this.refresh,
  }) : super(key: key);

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  void gp() async {
    if (widget.shot.url.isNotEmpty && widget.shot.image == null) {
      if (!widget.getPrecaching().contains(widget.shot.id)) {
        widget.precache(widget.shot);
      }
    } else if (widget.getWaiting() &&
        (widget.shot.url.isNotEmpty) &&
        widget.shot.image != null) {
      await Future.delayed(const Duration(seconds: 6));

      widget.setAuto(true);
      widget.setWaiting(false);
      widget.refresh();
    }
    if (kDebugMode) {
      print(
          'building ${widget.shot.id}, ${widget.shot.url} ${widget.shot.image.runtimeType} precaching:${widget.getPrecaching().contains(widget.shot.id)} ${widget.getPrecaching()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    gp();
    return IntrinsicHeight(
      child: GestureDetector(
          onTap: () {
            widget.setAuto(false);
            launchUrl(Uri.parse(widget.shot.url),
                mode: LaunchMode.externalApplication);
          },
          child: (widget.shot.url.isEmpty || widget.shot.image == null)
              ? GifView.asset('assets/images/loading.gif')
              : FittedBox(
                  fit: BoxFit.contain,
                  child: widget.shot.image,
                )),
    );
  }
}

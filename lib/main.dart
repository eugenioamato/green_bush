import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontFamily: 'PressStart2P',
          ))),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Video Revolution'),
    );
  }
}

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

  bool _auto = false;
  void getAuto() => _auto;
  void setAuto(v) => _auto = v;
  late final String apiKey;
  @override
  void initState() {
    apiKey = const String.fromEnvironment('API_KEY');
    if (kDebugMode) {
      print('API_KEY IS $apiKey');
    }
    super.initState();
  }

  int _page = 0;
  void setPage(page) {
    var range = 30;
    var len = src.length;
    if (len == 0) {
      _page = 0;
      return;
    }
    if (_page < page) {
      precache(src[(page + range) % len].url);
      CachedNetworkImage.evictFromCache(src[(page - range) % len].url);
    } else {
      precache(src[(page - range) % len].url);
      CachedNetworkImage.evictFromCache(src[(page + range) % len].url);
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
      CachedNetworkImage.evictFromCache(s.url);
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
        body: Center(child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 4,
                  child: SettingsWidget(
                    showActions: true,
                    orientation: orientation,
                    getActiveThreads: getActiveThreads,
                    refreshCallback: () {
                      setState(() {});
                    },
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
                Expanded(
                  flex: 8,
                  child: CarouselWidget(
                    src: src,
                    setPage: setPage,
                    getPage: getPage,
                    getAuto: getAuto,
                    focusNode: focusNode,
                    carouselController: carouselController,
                    autoplayCallback: () {
                      setState(() {
                        if (_auto) {
                          _auto = false;
                        } else {
                          _auto = true;
                        }
                      });
                    },
                  ),
                ),
                Flexible(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '${getPage()} / ${src.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
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
                      setAuto: setAuto,
                      getAuto: getAuto,
                    )),
                Flexible(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '${getPage()} / ${src.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
                Expanded(
                  flex: 8,
                  child: CarouselWidget(
                    src: src,
                    getAuto: getAuto,
                    setPage: setPage,
                    getPage: getPage,
                    focusNode: focusNode,
                    carouselController: carouselController,
                    autoplayCallback: () {
                      setState(() {
                        if (_auto) {
                          _auto = false;
                        } else {
                          _auto = true;
                        }
                      });
                    },
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
        })),
      ),
    );
  }

  void _startGeneration(
      prompt, nprompt, method, sampler, cfg, steps, seed, apiKey) async {
    if (kDebugMode) {
      print('starting from ${controller.text}');
    }
    setState(() {
      activeThreads++;
    });

    final data = <String, dynamic>{
      "model": method,
      "prompt": prompt,
      "negative_prompt": nprompt,
      "steps": steps,
      "cfg_scale": cfg,
      "sampler": sampler,
      "aspect_ratio": "landscape",
      "seed": seed,
      "upscale": true,
    };
    final str = jsonEncode(data);

    Dio dio = Dio();
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
        Shot(job, '', prompt, nprompt, cfg, steps, seed, method, sampler);
    src.add(earlyShot);
    setState(() {});

    String url = '';
    Future.delayed(const Duration(seconds: 5));

    int r = 0;
    do {
      final result2 = await dio.get("https://api.prodia.com/v1/job/$job",
          options: Options(headers: {
            "X-Prodia-Key": apiKey,
            'accept': 'application/json',
          }));
      final resp2 = jsonDecode(result2.toString());
      try {
        url = resp2['imageUrl'];
      } catch (e) {
        await Future.delayed(const Duration(seconds: 5));
        if (r > 30) {
          var index = -1;
          for (int i = 0; i < src.length; i++) {
            if (src[i].id == job) {
              index = i;
              break;
            }
          }
          if (index == -1) return;
          CachedNetworkImage.evictFromCache(url);
          src.removeAt(index);
          setState(() {});
          return;
        }
        r++;
      }
    } while (url.isEmpty);
    /*
    Image(
      image: CachedNetworkImageProvider(url),
    ).image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted) {
        activeThreads--;
        setState(() {});
        final bytes= PaintingBinding.instance.imageCache.currentSizeBytes;
        final maxbytes= PaintingBinding.instance.imageCache.maximumSizeBytes;
        print(':: $bytes / $maxbytes');
      }
    }));*/

    final updatedShot =
        Shot(job, url, prompt, nprompt, cfg, steps, seed, method, sampler);
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
      return;
    }
    src[index] = updatedShot;
    final page = getPage();
    if (index - page < 30 && index - page > -5) {
      if (url.isNotEmpty) precache(url);
    }

    activeThreads--;

    setState(() {});
  }

  void precache(url) {
    Image(
      image: CachedNetworkImageProvider(url),
    )
        .image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {});
        final bytes = PaintingBinding.instance.imageCache.currentSizeBytes;
        final maxbytes = PaintingBinding.instance.imageCache.maximumSizeBytes;
        if (kDebugMode) {
          print(':: $bytes / $maxbytes');
        }
      }
    }));
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
  final pool = Pool(80, timeout: const Duration(seconds: 21));

  void _multiSpan() {
    carouselController.jumpToPage(0);
    focusNode.requestFocus();
    for (var s in src) {
      CachedNetworkImage.evictFromCache(s.url);
    }
    setState(() {
      src.clear();
    });
    carouselController.jumpToPage(0);

    var prompt = controller.text;
    var nprompt = controller2.text;
    var seed = -1;
    if (seed == -1) {
      seed = Random().nextInt(199999999);
    }
    for (String method in methods) {
      for (String sampler in samplers) {
        for (int cfg = cfgSliderValue.toInt();
            cfg < cfgSliderEValue + 1;
            cfg++) {
          for (int steps = stepSliderValue.toInt();
              steps < stepSliderEValue + 1;
              steps += 1) {
            pool.withResource(() => _startGeneration(
                prompt, nprompt, method, sampler, cfg, steps, seed, apiKey));
          }
        }
      }
    }
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
                          value: widget.cfgSliderEValue,
                          min: widget.cfgSliderValue,
                          max: 30,
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
  const ActionsWidget(
      {Key? key,
      required this.controller,
      required this.controller2,
      required this.refreshCallback,
      required this.multispanCallback,
      required this.setAuto,
      required this.getAuto,
      required this.orientation,
      required this.getActiveThreads})
      : super(key: key);

  @override
  State<ActionsWidget> createState() => _ActionsWidgetState();
}

class _ActionsWidgetState extends State<ActionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Flex(
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
          child: Flex(direction: Axis.horizontal, children: [
            Expanded(
              child: IconButton(
                  onPressed: () => widget.multispanCallback(),
                  icon: Icon(
                    Icons.play_circle,
                    color: (widget.getActiveThreads() == 0
                        ? Colors.green
                        : widget.getActiveThreads() > 50
                            ? Colors.red
                            : Colors.orange),
                  )),
            ),
            if (widget.getAuto())
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        widget.setAuto(false);
                        widget.refreshCallback();
                      },
                      icon: const Icon(
                        Icons.brightness_auto_rounded,
                        color: Colors.green,
                      )))
            else
              Expanded(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.setAuto(true);
                      });
                      widget.refreshCallback();
                    },
                    icon: const Icon(
                      Icons.brightness_auto_outlined,
                      color: Colors.blue,
                    )),
              ),
            Text(':${widget.getActiveThreads()}')
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
  final Function autoplayCallback;
  final Function setPage;
  final Function getPage;
  final Function getAuto;
  const CarouselWidget(
      {Key? key,
      required this.src,
      required this.focusNode,
      required this.carouselController,
      required this.autoplayCallback,
      required this.getAuto,
      required this.setPage,
      required this.getPage})
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
          widget.autoplayCallback();
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
      child: CarouselSlider(
        items: widget.src
            .map((e) => Thumb(
                  label: e.label,
                  url: e.url,
                ))
            .toList(),
        carouselController: widget.carouselController,
        options: CarouselOptions(
          onPageChanged: (index, reason) {
            widget.setPage(index);
          },
          autoPlay: widget.getAuto(),
          autoPlayAnimationDuration: const Duration(milliseconds: 1),
          scrollDirection: Axis.vertical,
          enableInfiniteScroll: false,
          autoPlayInterval: const Duration(milliseconds: 300),
          viewportFraction: 0.99,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: controller,
              maxLines: orientation == Orientation.landscape ? 1 : 4,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 12),
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 8)),
            ),
          ),
        ),
        const Divider(
          color: Colors.white,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: controller2,
            maxLines: orientation == Orientation.landscape ? 1 : 4,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 8)),
          ),
        )),
        const Divider(
          color: Colors.white,
        ),
        const Spacer(),
      ],
    );
  }
}

class Shot implements Comparable<Shot> {
  Shot(this.id, this.url, this.prompt, this.nprompt, this.cfg, this.steps,
      this.seed, this.method, this.sampler);

  String get label => '$seed $method > $sampler $cfg $steps';
  final String id;
  final String prompt;
  final String nprompt;
  final String url;
  final int cfg;
  final int steps;
  final int seed;
  final String method;
  final String sampler;

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

class Thumb extends StatelessWidget {
  final String label;
  final String url;

  const Thumb({
    Key? key,
    required this.label,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: (url.isEmpty)
            ? GifView.asset('assets/images/loading.gif')
            : CachedNetworkImage(
                imageUrl: url,
                width: 1536,
                height: 1024,
                progressIndicatorBuilder: (c, s, p) => LinearProgressIndicator(
                  value: p.progress,
                  color: Colors.black,
                  backgroundColor: Colors.black,
                ),
              ));
  }
}

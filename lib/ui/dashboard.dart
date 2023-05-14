import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/services/txt_to_image.dart';
import 'package:green_bush/ui/actions_widget.dart';
import 'package:green_bush/ui/carousel_widget.dart';
import 'package:green_bush/ui/progress_slider.dart';
import 'package:green_bush/ui/settings_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';

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
  late final ImageRepository imageRepository;
  late final PlaybackState playbackState;
  late final TxtToImage txtToImage;

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

    imageRepository = ImageRepository(systemPreferences);
    playbackState = PlaybackState(imageRepository, systemPreferences);
    txtToImage = TxtToImage(playbackState, imageRepository, focusNode,
        systemPreferences, generationPreferences);

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
                                    multispanCallback: () =>
                                        txtToImage.multiSpan(
                                      setState,
                                      apiKey,
                                      controller.text,
                                      controller2.text,
                                    ),
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
                      multispanCallback: () => txtToImage.multiSpan(
                        setState,
                        apiKey,
                        controller.text,
                        controller2.text,
                      ),
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
                    child: ProgressSlider(
                        playbackState: playbackState,
                        carouselController: carouselController,
                        total: total,
                        refresh: refresh)),
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
                    multispanCallback: () => txtToImage.multiSpan(
                      setState,
                      apiKey,
                      controller.text,
                      controller2.text,
                    ),
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

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  createLabel(Shot s) {
    return '${s.seed} ${generationPreferences.models[s.method]} ${generationPreferences.samplers[s.sampler]} ${s.cfg} ${s.steps}';
  }
}

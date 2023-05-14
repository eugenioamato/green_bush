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
import 'package:wakelock/wakelock.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/keyboard_manager.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.title});
  final String title;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController controller = TextEditingController()
    ..text = "Green bush, awesome, ";
  final TextEditingController controller2 = TextEditingController()
    ..text = "cartoon, blur";
  final CarouselController carouselController = CarouselController();
  final GenerationPreferences generationPreferences = GenerationPreferences();
  final SystemPreferences systemPreferences = SystemPreferences();
  late final KeyboardManager keyboardManager;
  late final ImageRepository imageRepository;
  late final PlaybackState playbackState;
  late final TxtToImage txtToImage;
  late final String apiKey;

  @override
  void initState() {
    apiKey = const String.fromEnvironment('API_KEY');

    imageRepository = ImageRepository(systemPreferences);
    playbackState = PlaybackState(imageRepository, systemPreferences);
    txtToImage = TxtToImage(playbackState, imageRepository, focusNode,
        systemPreferences, generationPreferences);
    keyboardManager =
        KeyboardManager(playbackState, imageRepository, carouselController);
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
          final total = (imageRepository.getSrc().length) < 2
              ? 1
              : (imageRepository.getSrc().length) - 1;
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
                          imageRepository: imageRepository,
                          precache: imageRepository.poolprecache,
                          getPrecaching: imageRepository.getPrecaching,
                          focusNode: focusNode,
                          carouselController: carouselController,
                          refresh: refresh,
                          keyboardManager: keyboardManager,
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
                      ((imageRepository.getSrc().isNotEmpty) &&
                              (playbackState.getPage() <
                                  imageRepository.getSrc().length))
                          ? Align(
                              alignment: const Alignment(0, 0.90),
                              child: Text(
                                '${createLabel(imageRepository.getSrc()[playbackState.getPage()])}',
                                textAlign: TextAlign.center,
                              )
                              //color: (Colors.green),
                              )
                          : Container(),
                      Align(
                        alignment: const Alignment(-0.95, 0.95),
                        child: KeyboardListener(
                          onKeyEvent: (event) =>
                              keyboardManager.manageKeyEvent(event, refresh),
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
                          '${playbackState.getPage() + 1} / ${imageRepository.getSrc().length} / ${systemPreferences.totalrenders}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: KeyboardListener(
                    onKeyEvent: (event) =>
                        keyboardManager.manageKeyEvent(event, refresh),
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
                    '${playbackState.getPage()} / ${imageRepository.getSrc().length} / ${systemPreferences.totalrenders}',
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
                    imageRepository: imageRepository,
                    playbackState: playbackState,
                    precache: imageRepository.precache,
                    getPrecaching: imageRepository.getPrecaching,
                    focusNode: focusNode,
                    carouselController: carouselController,
                    refresh: refresh,
                    keyboardManager: keyboardManager,
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

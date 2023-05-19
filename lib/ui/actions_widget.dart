import 'package:flutter/material.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';
import 'package:green_bush/ui/prompt_widget.dart';
import 'package:green_bush/ui/settings_page.dart';

class ActionsWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final SystemPreferences systemPreferences;
  final GenerationPreferences generationPreferences;
  final TxtToImageInterface txtToImage;
  final PlaybackState playbackState;
  final Function refreshCallback;
  final Function multispanCallback;
  final Orientation orientation;

  const ActionsWidget({
    Key? key,
    required this.controller,
    required this.controller2,
    required this.refreshCallback,
    required this.multispanCallback,
    required this.orientation,
    required this.generationPreferences,
    required this.systemPreferences,
    required this.playbackState,
    required this.txtToImage,
  }) : super(key: key);

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
                        onPressed: widget.playbackState.sort,
                        icon: const Icon(
                          Icons.sort,
                          color: Colors.green,
                        ))),
                Expanded(
                    child: IconButton(
                        onPressed: () {
                          widget.playbackState.setAuto(false);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return SettingsPage(
                              systemPreferences: widget.systemPreferences,
                              generationPreferences:
                                  widget.generationPreferences,
                              playbackState: widget.playbackState,
                              txtToImage: widget.txtToImage,
                            );
                          }));
                        },
                        icon: Icon(
                          (widget.playbackState.getAuto()
                              ? Icons.settings
                              : Icons.settings),
                          color: (Colors.green),
                        ))),
                Expanded(
                  child: IconButton(
                      onPressed: () {
                        widget.multispanCallback();
                      },
                      icon: Icon(
                        Icons.add_task,
                        size: 32,
                        color: (widget.systemPreferences.getActiveThreads() == 0
                            ? Colors.green
                            : widget.systemPreferences.getActiveThreads() >
                                    widget.systemPreferences.maxThreads * 0.5
                                ? Colors.red
                                : Colors.orange),
                      )),
                ),
              ]),
        ),
      ],
    );
  }
}

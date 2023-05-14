import 'package:flutter/material.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/ui/prompt_widget.dart';
import 'package:green_bush/ui/settings_page.dart';

class ActionsWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final SystemPreferences systemPreferences;
  final GenerationPreferences generationPreferences;
  final PlaybackState playbackState;
  final Function refreshCallback;
  final Function multispanCallback;
  final Orientation orientation;
  final Function isModelEnabled;
  final Function toggleModel;
  final List<String> models;
  final List<String> samplers;
  final Function isSamplerEnabled;
  final Function toggleSampler;

  const ActionsWidget({
    Key? key,
    required this.controller,
    required this.controller2,
    required this.refreshCallback,
    required this.multispanCallback,
    required this.orientation,
    required this.isModelEnabled,
    required this.toggleModel,
    required this.models,
    required this.samplers,
    required this.isSamplerEnabled,
    required this.toggleSampler,
    required this.generationPreferences,
    required this.systemPreferences,
    required this.playbackState,
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
                        onPressed: () {
                          widget.playbackState.setAuto(false);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return SettingsPage(
                              systemPreferences: widget.systemPreferences,
                              getRandomSeed:
                                  widget.generationPreferences.getRandomSeed,
                              setRandomSeed:
                                  widget.generationPreferences.setRandomSeed,
                              isModelEnabled: widget.isModelEnabled,
                              toggleModel: widget.toggleModel,
                              models: widget.models,
                              samplers: widget.samplers,
                              toggleSampler: widget.toggleSampler,
                              isSamplerEnabled: widget.isSamplerEnabled,
                              getAutoDuration:
                                  widget.playbackState.getAutoDuration,
                              setAutoDuration:
                                  widget.playbackState.setAutoDuration,
                              getUpscale:
                                  widget.generationPreferences.getUpscale,
                              setUpscale:
                                  widget.generationPreferences.setUpscale,
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

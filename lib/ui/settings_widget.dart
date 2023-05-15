import 'package:flutter/material.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';

import 'actions_widget.dart';

class SettingsWidget extends StatefulWidget {
  final GenerationPreferences generationPreferences;
  final SystemPreferences systemPreferences;
  final PlaybackState playbackState;
  final bool showActions;
  final Orientation orientation;
  final TxtToImageInterface txtToImage;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function refreshCallback;
  final Function multispanCallback;

  const SettingsWidget({
    Key? key,
    required this.refreshCallback,
    required this.multispanCallback,
    required this.controller,
    required this.controller2,
    required this.showActions,
    required this.orientation,
    required this.generationPreferences,
    required this.systemPreferences,
    required this.playbackState,
    required this.txtToImage,
    required TxtToImageInterface txtToImageInterface,
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
                          value: widget.generationPreferences.cfgSliderValue,
                          min: 1,
                          max: widget.generationPreferences.cfgSliderEValue,
                          onChanged: (v) {
                            widget.generationPreferences.setCfgSliderValue(v);
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
                          value: widget.generationPreferences.stepSliderValue,
                          min: 1,
                          max: widget.generationPreferences.stepSliderEValue,
                          onChanged: (v) {
                            widget.generationPreferences.setStepSliderValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    'CFG :${widget.generationPreferences.cfgSliderValue.toInt()} - ${widget.generationPreferences.cfgSliderEValue.toInt()}',
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
                          value: widget.generationPreferences.cfgSliderEValue,
                          min: widget.generationPreferences.cfgSliderValue,
                          max: 20,
                          onChanged: (v) {
                            widget.generationPreferences.setCfgSliderEValue(v);
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
                          value: widget.generationPreferences.stepSliderEValue,
                          min: widget.generationPreferences.stepSliderValue,
                          max: 50,
                          onChanged: (v) {
                            widget.generationPreferences.setStepSliderEValue(v);
                            widget.refreshCallback();
                          }),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    'STEP:${widget.generationPreferences.stepSliderValue.toInt()} - ${widget.generationPreferences.stepSliderEValue.toInt()}',
                  )),
                ],
              )),
          if (widget.showActions)
            Flexible(
                flex: 1,
                child: ActionsWidget(
                  generationPreferences: widget.generationPreferences,
                  systemPreferences: widget.systemPreferences,
                  playbackState: widget.playbackState,
                  controller2: widget.controller2,
                  controller: widget.controller,
                  orientation: widget.orientation,
                  multispanCallback: widget.multispanCallback,
                  refreshCallback: widget.refreshCallback,
                  txtToImage: widget.txtToImage,
                )),
        ],
      ),
    );
  }
}

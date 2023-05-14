import 'package:flutter/material.dart';
import 'package:green_bush/services/generation_preferences.dart';

import 'actions_widget.dart';

class SettingsWidget extends StatefulWidget {
  final GenerationPreferences generationPreferences;
  final bool showActions;
  final int maxThreads;
  final Orientation orientation;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function isModelEnabled;
  final Function toggleModel;
  final List<String> models;
  final List<String> samplers;
  final Function isSamplerEnabled;
  final Function toggleSampler;
  final Function getActiveThreads;
  final Function refreshCallback;
  final Function multispanCallback;
  final Function setAuto;
  final Function getAuto;
  final Function getAutoDuration;
  final Function setAutoDuration;
  final Function getRange;
  final Function setRange;

  const SettingsWidget({
    Key? key,
    required this.refreshCallback,
    required this.multispanCallback,
    required this.setAuto,
    required this.getAuto,
    required this.controller,
    required this.controller2,
    required this.showActions,
    required this.orientation,
    required this.getActiveThreads,
    required this.maxThreads,
    required this.isModelEnabled,
    required this.toggleModel,
    required this.models,
    required this.samplers,
    required this.isSamplerEnabled,
    required this.toggleSampler,
    required this.getAutoDuration,
    required this.setAutoDuration,
    required this.getRange,
    required this.setRange,
    required this.generationPreferences,
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
                  isModelEnabled: widget.isModelEnabled,
                  toggleModel: widget.toggleModel,
                  models: widget.models,
                  maxThreads: widget.maxThreads,
                  controller2: widget.controller2,
                  controller: widget.controller,
                  getRange: widget.getRange,
                  setRange: widget.setRange,
                  orientation: widget.orientation,
                  multispanCallback: widget.multispanCallback,
                  refreshCallback: widget.refreshCallback,
                  setAuto: widget.setAuto,
                  getAuto: widget.getAuto,
                  getActiveThreads: widget.getActiveThreads,
                  samplers: widget.samplers,
                  isSamplerEnabled: widget.isSamplerEnabled,
                  toggleSampler: widget.toggleSampler,
                  getAutoDuration: widget.getAutoDuration,
                  setAutoDuration: widget.setAutoDuration,
                )),
        ],
      ),
    );
  }
}

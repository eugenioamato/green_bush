import 'package:flutter/material.dart';

import 'actions_widget.dart';

class SettingsWidget extends StatefulWidget {
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
  final Function getAutoDuration;
  final Function setAutoDuration;

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
    required this.maxThreads,
    required this.isModelEnabled,
    required this.toggleModel,
    required this.models,
    required this.samplers,
    required this.isSamplerEnabled,
    required this.toggleSampler,
    required this.getAutoDuration,
    required this.setAutoDuration,
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
                  isModelEnabled: widget.isModelEnabled,
                  toggleModel: widget.toggleModel,
                  models: widget.models,
                  maxThreads: widget.maxThreads,
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

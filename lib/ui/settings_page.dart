import 'package:flutter/material.dart';
import 'package:green_bush/services/generation_preferences.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';

class SettingsPage extends StatefulWidget {
  final SystemPreferences systemPreferences;
  final GenerationPreferences generationPreferences;
  final PlaybackState playbackState;
  const SettingsPage(
      {Key? key,
      required this.systemPreferences,
      required this.generationPreferences,
      required this.playbackState})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, bool> checkModels = {};
  Map<String, bool> checkSamplers = {};

  @override
  void initState() {
    for (int i = 0; i < widget.generationPreferences.models.length; i++) {
      checkModels.addAll({
        widget.generationPreferences.models[i]:
            widget.generationPreferences.isModelEnabled(i)
      });
    }
    for (int i = 0; i < widget.generationPreferences.samplers.length; i++) {
      checkSamplers.addAll({
        widget.generationPreferences.samplers[i]:
            widget.generationPreferences.isSamplerEnabled(i)
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mbit = 5200 / widget.playbackState.getAutoDuration();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Flex(
        direction: Axis.vertical,
        children: [
          const Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 14,
            child: ListView(
              children: [
                Card(
                  color: Colors.black,
                  child: Column(
                    children: [
                      const Text('Randomize seed'),
                      Checkbox(
                        value: widget.generationPreferences.getRandomSeed(),
                        onChanged: (v) => setState(() {
                          widget.generationPreferences.setRandomSeed(v);
                        }),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Column(
                    children: [
                      const Text('Upscale images'),
                      Checkbox(
                        value: widget.generationPreferences.getUpscale(),
                        onChanged: (v) => setState(() {
                          widget.generationPreferences.setUpscale(v);
                        }),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Column(
                    children: [
                      Text(
                          'Autoplay duration (msec): ${widget.playbackState.getAutoDuration()} at ${mbit.toStringAsFixed(2)} MBIT'),
                      Slider.adaptive(
                          divisions: 59950,
                          min: 50,
                          max: 60000,
                          value:
                              widget.playbackState.getAutoDuration().toDouble(),
                          onChanged: (v) {
                            setState(() {
                              widget.playbackState.setAutoDuration(v.toInt());
                            });
                          })
                    ],
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Column(
                    children: [
                      Text(
                          'Cache range: ${widget.systemPreferences.getRange()}'),
                      Slider.adaptive(
                          min: 1,
                          max: 10000,
                          divisions: 10000,
                          value: widget.systemPreferences.getRange().toDouble(),
                          onChanged: (r) {
                            setState(() {
                              widget.systemPreferences.setRange(r.toInt());
                            });
                          })
                    ],
                  ),
                ),
                ExpansionTile(
                  title: const Text('Change Model selection'),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          children: checkModels.keys.map((String key) {
                            return CheckboxListTile(
                              title: Text(key),
                              value: checkModels[key],
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null) {
                                    checkModels[key] = value;
                                    final index = widget
                                        .generationPreferences.models
                                        .indexOf(key);
                                    widget.generationPreferences
                                        .toggleModel(index);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: const Text('Change Sampler selection'),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          children: checkSamplers.keys.map((String key) {
                            return CheckboxListTile(
                              title: Text(key),
                              value: checkSamplers[key],
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null) {
                                    checkSamplers[key] = value;
                                    final index = widget
                                        .generationPreferences.samplers
                                        .indexOf(key);
                                    widget.generationPreferences
                                        .toggleSampler(index);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
              child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(checkModels.values);
            },
          )),
          const Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

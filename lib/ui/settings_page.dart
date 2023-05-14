import 'package:flutter/material.dart';
import 'package:green_bush/services/system_preferences.dart';

class SettingsPage extends StatefulWidget {
  final SystemPreferences systemPreferences;
  final Function getRandomSeed;
  final Function setRandomSeed;
  final List<String> models;
  final Function isModelEnabled;
  final Function toggleModel;
  final List<String> samplers;
  final Function isSamplerEnabled;
  final Function toggleSampler;
  final Function getAutoDuration;
  final Function setAutoDuration;
  final Function getUpscale;
  final Function setUpscale;

  const SettingsPage(
      {Key? key,
      required this.getRandomSeed,
      required this.setRandomSeed,
      required this.isModelEnabled,
      required this.toggleModel,
      required this.models,
      required this.samplers,
      required this.isSamplerEnabled,
      required this.toggleSampler,
      required this.getAutoDuration,
      required this.setAutoDuration,
      required this.getUpscale,
      required this.setUpscale,
      required this.systemPreferences})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, bool> checkModels = {};
  Map<String, bool> checkSamplers = {};

  @override
  void initState() {
    for (int i = 0; i < widget.models.length; i++) {
      checkModels.addAll({widget.models[i]: widget.isModelEnabled(i)});
    }
    for (int i = 0; i < widget.samplers.length; i++) {
      checkSamplers.addAll({widget.samplers[i]: widget.isSamplerEnabled(i)});
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mbit = 5200 / widget.getAutoDuration();
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
                        value: widget.getRandomSeed(),
                        onChanged: (v) => setState(() {
                          widget.setRandomSeed(v);
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
                        value: widget.getUpscale(),
                        onChanged: (v) => setState(() {
                          widget.setUpscale(v);
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
                          'Autoplay duration (msec): ${widget.getAutoDuration()} at ${mbit.toStringAsFixed(2)} MBIT'),
                      Slider.adaptive(
                          divisions: 59950,
                          min: 50,
                          max: 60000,
                          value: widget.getAutoDuration().toDouble(),
                          onChanged: (v) {
                            setState(() {
                              widget.setAutoDuration(v.toInt());
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
                                    final index = widget.models.indexOf(key);
                                    widget.toggleModel(index);
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
                                    final index = widget.samplers.indexOf(key);
                                    widget.toggleSampler(index);
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

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function getRandomSeed;
  final Function setRandomSeed;
  final List<String> models;
  final Function isModelEnabled;
  final Function toggleModel;
  final List<String> samplers;
  final Function isSamplerEnabled;
  final Function toggleSampler;

  const SettingsPage(
      {Key? key,
      required this.getRandomSeed,
      required this.setRandomSeed,
      required this.isModelEnabled,
      required this.toggleModel,
      required this.models,
      required this.samplers,
      required this.isSamplerEnabled,
      required this.toggleSampler})
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
            icon: const Icon(Icons.save),
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

import 'package:flutter/material.dart';
import 'package:green_bush/ui/prompt_widget.dart';
import 'package:green_bush/ui/settings_page.dart';

class ActionsWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function refreshCallback;
  final Function multispanCallback;
  final Function setAuto;
  final Function getAuto;
  final Function getActiveThreads;
  final Orientation orientation;
  final Function getRandomSeed;
  final Function setRandomSeed;
  final Function isModelEnabled;
  final Function toggleModel;
  final List<String> models;
  final List<String> samplers;
  final Function isSamplerEnabled;
  final Function toggleSampler;
  final Function getAutoDuration;
  final Function setAutoDuration;

  final int maxThreads;
  const ActionsWidget(
      {Key? key,
      required this.controller,
      required this.controller2,
      required this.refreshCallback,
      required this.multispanCallback,
      required this.setAuto,
      required this.getAuto,
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
      required this.setAutoDuration})
      : super(key: key);

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
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return SettingsPage(
                              getRandomSeed: widget.getRandomSeed,
                              setRandomSeed: widget.setRandomSeed,
                              isModelEnabled: widget.isModelEnabled,
                              toggleModel: widget.toggleModel,
                              models: widget.models,
                              samplers: widget.samplers,
                              toggleSampler: widget.toggleSampler,
                              isSamplerEnabled: widget.isSamplerEnabled,
                              getAutoDuration: widget.getAutoDuration,
                              setAutoDuration: widget.setAutoDuration,
                            );
                          }));
                        },
                        icon: Icon(
                          (widget.getAuto() ? Icons.settings : Icons.settings),
                          color: (Colors.green),
                        ))),
                Expanded(
                  child: IconButton(
                      onPressed: () {
                        widget.multispanCallback();
                      },
                      icon: Icon(
                        Icons.generating_tokens,
                        color: (widget.getActiveThreads() == 0
                            ? Colors.green
                            : widget.getActiveThreads() >
                                    widget.maxThreads * 0.5
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

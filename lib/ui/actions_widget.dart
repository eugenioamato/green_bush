import 'package:flutter/material.dart';
import 'package:green_bush/ui/prompt_widget.dart';

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
      required this.maxThreads})
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
                          setState(() {
                            widget.setAuto(!widget.getAuto());
                          });
                          widget.refreshCallback();
                        },
                        icon: Icon(
                          (widget.getAuto()
                              ? Icons.play_circle
                              : Icons.play_circle_outline),
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
                Expanded(
                    child: Checkbox(
                  value: widget.getRandomSeed(),
                  onChanged: (v) => widget.setRandomSeed(v),
                )),
              ]),
        ),
      ],
    );
  }
}

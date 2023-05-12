import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function getRandomSeed;
  final Function setRandomSeed;
  const SettingsPage(
      {Key? key, required this.getRandomSeed, required this.setRandomSeed})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                        onChanged: (v) => widget.setRandomSeed(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
              child: IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.of(context).pop();
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

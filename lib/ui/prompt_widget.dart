import 'package:flutter/material.dart';

class PromptsWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController controller2;
  final Orientation orientation;
  const PromptsWidget(
      {Key? key,
      required this.controller,
      required this.controller2,
      required this.orientation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Card(
            color: Colors.black,
            child: TextField(
              controller: controller,
              maxLines: orientation == Orientation.landscape ? 1 : 4,
              showCursor: true,
              //cursorColor: Colors.yellow,
              cursorHeight: 10,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 10),
            ),
          ),
        ),
        Expanded(
            child: Card(
          color: Colors.black,
          child: TextField(
            controller: controller2,
            maxLines: orientation == Orientation.landscape ? 1 : 4,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10),
          ),
        )),
      ],
    );
  }
}

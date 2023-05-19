import 'package:flutter/material.dart';

class LikeWidget extends StatelessWidget {
  final AnimationController animationController;
  const LikeWidget({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: const Icon(
        Icons.heart_broken,
        color: Colors.red,
        size: 64,
      ),
      builder: (context, child) {
        return Transform.scale(
          scale: animationController.value,
          child: child,
        );
      },
    );
  }
}

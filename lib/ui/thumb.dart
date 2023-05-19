import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/file_service.dart';

class Thumb extends StatelessWidget {
  final Shot shot;

  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final Function refresh;
  final String label;
  final String extension;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function runAnimation;

  const Thumb({
    Key? key,
    required this.shot,
    required this.refresh,
    required this.playbackState,
    required this.imageRepository,
    required this.controller,
    required this.controller2,
    required this.runAnimation,
    required this.label,
    required this.extension,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('building ${shot.diff} blob is ${shot.blob.length}');
    }
    return GestureDetector(
      onTap: () {
        playbackState.setAuto(false);
        FileService().saveFile(
          shot.blob,
          label,
          controller.text,
          controller2.text,
          extension,
        );
        runAnimation();
      },
      child: (shot.url.isEmpty || shot.blob.isEmpty)
          ? GifView.asset('assets/images/loading.gif')
          : FittedBox(
              fit: BoxFit.contain,
              child: Container(
                constraints: const BoxConstraints(minHeight: 1, minWidth: 1),
                child: Image.memory(shot.blob),
              ),
            ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';

import '../services/file_service.dart';

class Thumb extends StatefulWidget {
  final Shot shot;
  final Function setAuto;
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final Function refresh;
  final String label;
  final Uint8List blob;
  final String extension;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function runAnimation;

  const Thumb({
    Key? key,
    required this.shot,
    required this.setAuto,
    required this.refresh,
    required this.playbackState,
    required this.imageRepository,
    required this.controller,
    required this.controller2,
    required this.runAnimation,
    required this.label,
    required this.blob,
    required this.extension,
  }) : super(key: key);

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: GestureDetector(
          onTap: () {
            widget.setAuto(false);
            FileService().saveFile(
              widget.blob,
              widget.label,
              widget.controller.text,
              widget.controller2.text,
              widget.extension,
            );
            widget.runAnimation();
          },
          child: (widget.shot.url.isEmpty || widget.blob.isEmpty)
              ? GifView.asset('assets/images/loading.gif')
              : FittedBox(
                  fit: BoxFit.contain, child: Image.memory(widget.blob))),
    );
  }
}

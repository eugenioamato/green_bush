import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';

import '../services/file_service.dart';

class Thumb extends StatefulWidget {
  final Shot shot;
  final Function setAuto;
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final Function precache;
  final Function getPrecaching;
  final Function refresh;
  final Function createLabel;
  final TxtToImageInterface txtToImage;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function runAnimation;

  const Thumb({
    Key? key,
    required this.shot,
    required this.setAuto,
    required this.precache,
    required this.getPrecaching,
    required this.refresh,
    required this.playbackState,
    required this.imageRepository,
    required this.createLabel,
    required this.controller,
    required this.controller2,
    required this.txtToImage,
    required this.runAnimation,
  }) : super(key: key);

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  void gp() async {
    if (widget.shot.url.isNotEmpty &&
        widget.imageRepository.getImage(widget.shot.index) == null) {
      if (!widget.getPrecaching().contains(widget.shot.id)) {
        widget.precache(widget.shot, widget.playbackState, true);
      }
    }
    if (kDebugMode) {
      print(
          'building ${widget.shot.id}, ${widget.shot.url} ${widget.imageRepository.getImage(widget.shot.index).runtimeType} precaching:${widget.getPrecaching().contains(widget.shot.id)} ${widget.getPrecaching()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    gp();
    return IntrinsicHeight(
      child: GestureDetector(
          onTap: () {
            widget.setAuto(false);
            String id = widget.createLabel(
                widget.imageRepository.getShot(widget.playbackState.getPage()));
            FileService().saveFile(
              widget.imageRepository.getBlob(widget.playbackState.getPage()),
              id,
              widget.controller.text,
              widget.controller2.text,
              widget.txtToImage.extension,
            );
            widget.runAnimation();
          },
          child: (widget.shot.url.isEmpty ||
                  widget.imageRepository.getImage(widget.shot.index) == null)
              ? GifView.asset('assets/images/loading.gif')
              : FittedBox(
                  fit: BoxFit.contain,
                  child: widget.imageRepository.getImage(widget.shot.index),
                )),
    );
  }
}

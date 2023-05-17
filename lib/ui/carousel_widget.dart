import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/keyboard_manager.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';
import 'package:green_bush/ui/thumb.dart' as th;

import '../services/image_repository.dart';
import '../services/playback_state.dart';

class CarouselWidget extends StatefulWidget {
  final PlaybackState playbackState;
  final FocusNode focusNode;
  final CarouselController carouselController;
  final ImageRepository imageRepository;
  final Function refresh;
  final KeyboardManager keyboardManager;
  final Function createLabel;
  final TextEditingController controller;
  final TextEditingController controller2;
  final TxtToImageInterface txtToImage;
  final Function runAnimation;

  const CarouselWidget({
    Key? key,
    required this.focusNode,
    required this.carouselController,
    required this.refresh,
    required this.playbackState,
    required this.keyboardManager,
    required this.imageRepository,
    required this.createLabel,
    required this.controller,
    required this.controller2,
    required this.txtToImage,
    required this.runAnimation,
  }) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusNode,
      autofocus: true,
      onKeyEvent: (event) =>
          widget.keyboardManager.manageKeyEvent(event, widget.refresh),
      child: Container(
        constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
        child: CarouselSlider(
          items: widget.imageRepository
              .loadedElements()
              .map((e) => th.Thumb(
                    runAnimation: widget.runAnimation,
                    controller: widget.controller,
                    controller2: widget.controller2,
                    imageRepository: widget.imageRepository,
                    shot: widget.imageRepository.getShot(e),
                    setAuto: widget.playbackState.setAuto,
                    refresh: widget.refresh,
                    playbackState: widget.playbackState,
                    label:
                        widget.createLabel(widget.imageRepository.getShot(e)),
                    extension: widget.txtToImage.extension,
                    blob: widget.imageRepository.getBlob(e),
                  ))
              .toList(),
          carouselController: widget.carouselController,
          options: CarouselOptions(
            initialPage: widget.playbackState.getPage(),
            onPageChanged: (index, reason) {
              widget.playbackState.setPage(index, widget.refresh);
            },
            pauseAutoPlayOnTouch: true,
            autoPlay: widget.playbackState.getAuto(),
            autoPlayAnimationDuration: const Duration(milliseconds: 1),
            scrollDirection: Axis.vertical,
            enableInfiniteScroll: false,
            autoPlayInterval:
                Duration(milliseconds: widget.playbackState.getAutoDuration()),
            viewportFraction: 0.99,
          ),
        ),
      ),
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/keyboard_manager.dart';
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

  const CarouselWidget({
    Key? key,
    required this.focusNode,
    required this.carouselController,
    required this.refresh,
    required this.playbackState,
    required this.keyboardManager,
    required this.imageRepository,
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
      child: IntrinsicHeight(
        child: CarouselSlider(
          items: List.generate(widget.imageRepository.getLen(), (v) => v)
              .map((e) => th.Thumb(
                    imageRepository: widget.imageRepository,
                    shot: widget.imageRepository.getShot(e),
                    setAuto: widget.playbackState.setAuto,
                    precache: widget.imageRepository.poolprecache,
                    getPrecaching: widget.imageRepository.getPrecaching,
                    refresh: widget.refresh,
                    playbackState: widget.playbackState,
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
            viewportFraction: 1.0,
          ),
        ),
      ),
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/ui/thumb.dart' as th;

import '../services/playback_state.dart';

class CarouselWidget extends StatefulWidget {
  final List src;
  final PlaybackState playbackState;
  final FocusNode focusNode;
  final CarouselController carouselController;
  final Function precache;
  final Function getPrecaching;
  final void Function(KeyEvent) manageKeyEvent;
  final Function refresh;

  const CarouselWidget({
    Key? key,
    required this.src,
    required this.focusNode,
    required this.carouselController,
    required this.precache,
    required this.getPrecaching,
    required this.refresh,
    required this.manageKeyEvent,
    required this.playbackState,
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
      onKeyEvent: widget.manageKeyEvent,
      child: IntrinsicHeight(
        child: CarouselSlider(
          items: widget.src
              .map((e) => th.Thumb(
                    shot: e,
                    setAuto: widget.playbackState.setAuto,
                    precache: widget.precache,
                    getPrecaching: widget.getPrecaching,
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

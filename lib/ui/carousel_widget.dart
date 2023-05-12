import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/ui/thumb.dart' as th;

class CarouselWidget extends StatefulWidget {
  final List src;
  final FocusNode focusNode;
  final CarouselController carouselController;
  final Function setPage;
  final Function getPage;
  final Function getAuto;
  final Function precache;
  final Function getPrecaching;
  final void Function(KeyEvent) manageKeyEvent;

  final Function setWaiting;
  final Function getWaiting;
  final Function refresh;

  final Function setAuto;
  const CarouselWidget(
      {Key? key,
      required this.src,
      required this.focusNode,
      required this.carouselController,
      required this.getAuto,
      required this.setPage,
      required this.getPage,
      required this.setAuto,
      required this.precache,
      required this.getPrecaching,
      required this.setWaiting,
      required this.getWaiting,
      required this.refresh,
      required this.manageKeyEvent})
      : super(key: key);

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
                    setAuto: widget.setAuto,
                    precache: widget.precache,
                    getPrecaching: widget.getPrecaching,
                    getWaiting: widget.getWaiting,
                    refresh: widget.refresh,
                    setWaiting: widget.setWaiting,
                  ))
              .toList(),
          carouselController: widget.carouselController,
          options: CarouselOptions(
            initialPage: widget.getPage(),
            onPageChanged: (index, reason) {
              widget.setPage(index);
            },
            pauseAutoPlayOnTouch: true,
            autoPlay: widget.getAuto(),
            autoPlayAnimationDuration: const Duration(milliseconds: 1),
            scrollDirection: Axis.vertical,
            enableInfiniteScroll: false,
            autoPlayInterval: const Duration(milliseconds: 800),
            viewportFraction: 1.0,
          ),
        ),
      ),
    );
  }
}

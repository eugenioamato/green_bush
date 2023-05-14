import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/playback_state.dart';

class ProgressSlider extends StatefulWidget {
  final PlaybackState playbackState;
  final CarouselController carouselController;
  final int total;
  final Function refresh;
  const ProgressSlider(
      {Key? key,
      required this.playbackState,
      required this.carouselController,
      required this.total,
      required this.refresh})
      : super(key: key);

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  @override
  Widget build(BuildContext context) {
    final double loaded = (widget.playbackState.getLoading());
    return Slider(
      min: 0,
      max: widget.total.toDouble(),
      secondaryTrackValue:
          ((loaded >= 0) && (loaded <= widget.total)) ? loaded : 0.0,
      secondaryActiveColor: Colors.lightGreen,
      divisions: widget.total,
      thumbColor: Colors.green,
      inactiveColor: Colors.yellow.withOpacity(0.2),
      activeColor: widget.playbackState.getComplete()
          ? Colors.lightGreen
          : Colors.yellow.withOpacity(0.2),
      value: (widget.playbackState.getPage() > widget.total
          ? widget.total.toDouble()
          : widget.playbackState.getPage().toDouble()),
      onChangeStart: (newPage) {
        widget.playbackState.setAuto(false);
        widget.playbackState.setDisableCaching(true);
      },
      onChangeEnd: (newPage) {
        widget.playbackState.setDisableCaching(false);
        widget.playbackState
            .setPage(widget.playbackState.getPage(), widget.refresh);
      },
      onChanged: (double value) {
        setState(() {
          widget.carouselController.jumpToPage((value).toInt());
        });
      },
    );
  }
}

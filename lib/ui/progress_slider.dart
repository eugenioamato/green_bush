import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/playback_state.dart';

class ProgressSlider extends StatefulWidget {
  final PlaybackState playbackState;
  final CarouselController carouselController;
  final ImageRepository imageRepository;
  final int total;
  final int errors;
  final Function refresh;
  const ProgressSlider(
      {Key? key,
      required this.playbackState,
      required this.carouselController,
      required this.total,
      required this.refresh,
      required this.imageRepository,
      required this.errors})
      : super(key: key);

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  @override
  Widget build(BuildContext context) {
    final double loaded = widget.imageRepository.loadedElementsLen().toDouble();
    final errorRatio = widget.errors;
    final int loadingRatio = widget.total - (loaded.toInt() + errorRatio);
    var secondary = widget.imageRepository.getSortProgress();
    if (secondary == null) {
      secondary = 0.0;
    } else {
      if (secondary < 0) {
        secondary = 0.0;
      } else if (secondary > loaded) {
        secondary = loaded;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: loaded.toInt() + 1,
            child: SliderTheme(
              data: SliderThemeData(
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbColor: Colors.red,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6)),
              child: Slider.adaptive(
                min: 0,
                max: loaded,
                secondaryTrackValue: secondary,
                inactiveColor: Colors.yellow.withOpacity(0.2),
                activeColor: Colors.lightGreen,
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
              ),
            ),
          ),
          Expanded(
              flex: loadingRatio,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 4),
                color: Colors.grey,
              )),
          Expanded(
              flex: errorRatio,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 4),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(2),
                      topRight: Radius.circular(2),
                    ),
                    color: Colors.red),
              )),
        ],
      ),
    );
  }
}

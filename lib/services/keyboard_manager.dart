import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:green_bush/models/shot.dart';
import 'package:green_bush/services/image_repository.dart';

class KeyboardManager {
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final CarouselController carouselController;

  KeyboardManager(
    this.playbackState,
    this.imageRepository,
    this.carouselController,
  );

  var _pressed = false;
  void manageKeyEvent(KeyEvent event, Function refresh) {
    if (event.logicalKey.keyId == 32) {
      playbackState.setAuto(false);
      Shot shot = imageRepository.getShot(playbackState.getPage());
      launchUrl(Uri.parse(shot.url), mode: LaunchMode.externalApplication);
    } else if (event.logicalKey.keyId == 115) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.nextPage(duration: const Duration(milliseconds: 1));
        _pressed = true;
      }
    } else if (event.logicalKey.keyId == 119) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.previousPage(
            duration: const Duration(milliseconds: 1));
        _pressed = true;
      }
    } else if (event.logicalKey.keyId == 100) {
      if (_pressed) {
        _pressed = false;
      } else {
        playbackState.setAuto(!playbackState.getAuto());
        _pressed = true;
        refresh();
      }
    } else if (event.logicalKey.keyId == 97) {
      if (_pressed) {
        _pressed = false;
      } else {
        carouselController.jumpToPage(0);
        _pressed = true;
      }
    }
  }
}

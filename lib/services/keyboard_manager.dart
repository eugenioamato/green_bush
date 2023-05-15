import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/image_repository.dart';
import 'package:green_bush/services/txt_to_image_interface.dart';

import '../models/shot.dart';
import 'file_service.dart';

class KeyboardManager {
  final PlaybackState playbackState;
  final ImageRepository imageRepository;
  final CarouselController carouselController;
  final TxtToImageInterface txtToImage;
  final TextEditingController controller;
  final TextEditingController controller2;
  final Function runAnimation;

  KeyboardManager(
    this.playbackState,
    this.imageRepository,
    this.carouselController,
    this.controller,
    this.controller2,
    this.txtToImage,
    this.runAnimation,
  );

  String createLabel(Shot s) {
    return '${s.seed} ${txtToImage.allmodels()[s.model]} ${txtToImage.allsamplers()[s.sampler]} ${s.cfg} ${s.steps}';
  }

  var _pressed = false;
  void manageKeyEvent(KeyEvent event, Function refresh) async {
    if (event.logicalKey.keyId == 32) {
      playbackState.setAuto(false);
      String id = createLabel(imageRepository.getShot(playbackState.getPage()));
      final result = FileService().saveFile(
        imageRepository.getBlob(playbackState.getPage()),
        id,
        controller.text,
        controller2.text,
        txtToImage.extension,
      );
      if (await result) {
        runAnimation();
      }
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

import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:pool/pool.dart';

import '../models/shot.dart';

Shot fakeShot(int index) => Shot('-1', '', '', '', 0, 0, 0, 0, 0, index);

class ImageRepository {
  late final Pool pool;
  final SystemPreferences systemPreferences;
  final Function refresh;
  ImageRepository(
    this.systemPreferences,
    this.refresh,
  ) {
    pool = Pool(systemPreferences.maxDownloads,
        timeout: const Duration(seconds: 16));
  }

  final HashMap<int, Uint8List> _blob = HashMap<int, Uint8List>();
  final HashMap<int, Shot> _src = HashMap<int, Shot>();
  final HashMap<int, Image> _img = HashMap<int, Image>();

  Uint8List getBlob(int page) =>
      _blob.containsKey(page) ? _blob[page]! : Uint8List(0);
  void setBlob(int index, Uint8List data) => _blob[index] = data;
  Image? getImage(int index) => _img.containsKey(index) ? _img[index] : null;
  void setImage(int index, Image image) => _img[index] = image;
  Shot getShot(int index) =>
      (_src.containsKey(index)) ? _src[index]! : fakeShot(index);
  void addShot(int index, Shot s) => _src[index] = s;
  void removeAt(int index) {
    _src[index] = fakeShot(index);
  }

  Iterable<Shot> getSrc() => _src.values;
  int getLen() => _src.length;

  void removeFromCache(Shot s) {
    if (s.url.length > 1) {
      int index = s.index;
      _img[index]?.image.evict();
      _img.remove(index);
    }
  }

  Set<String> precaching = {};
  Set<String> getPrecaching() => precaching;

  void poolprecache(Shot s, PlaybackState playbackState, bool priority) {
    if (getBlob(s.index).isNotEmpty) {
      setImage(s.index, Image.memory(getBlob(s.index)));
      refresh();
      return;
    }
    if (priority) {
      _precache(s, playbackState);
    } else {
      if (precaching.length > systemPreferences.maxDownloads) return;
      if (s.url.length > 1) {
        pool.withResource(() => _precache(s, playbackState));
      }
    }
  }

  void _precache(Shot s, PlaybackState playbackState) {
    if ((getPrecaching().contains(s.id))) return;

    if (getImage(s.index) != null) return;
    final url = s.url;
    if (url.isEmpty) return;
    if (playbackState.getDisableCaching()) {
      if (kDebugMode) {
        print('disabled precaching, stopped ${s.id}');
      }
      return;
    }

    getPrecaching().add(s.id);
    if (kDebugMode) {
      print('starting precache ${s.id}');
    }

    //refresh();
    late final Image image;
    try {
      image = Image(
        image: Image.network(
          url,
        ).image,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error creating image $e');
      }
      refresh();
      return;
    }

    systemPreferences.activeDownloads++;
    try {
      final resolver = image.image.resolve(const ImageConfiguration());
      resolver.addListener(ImageStreamListener((data, __) async {
        if (kDebugMode) {
          final bytes = PaintingBinding.instance.imageCache.currentSizeBytes;
          final maxbytes = PaintingBinding.instance.imageCache.maximumSizeBytes;

          print(':: $bytes / $maxbytes');
        }
        getPrecaching().remove(s.id);
        if (kDebugMode) {
          print('ending    precache ${s.id} ${getPrecaching()} }');
        }
        final byteData =
            await data.image.toByteData(format: ImageByteFormat.png);
        final bufferData = byteData?.buffer.asUint8List();
        if (bufferData != null) {
          setBlob(s.index, bufferData);
        }
        playbackState.updateSecondarySlider();
        setImage(s.index, image);
        systemPreferences.activeDownloads--;
        refresh();
        playbackState.updateSecondarySlider();
      }, onError: (e, stack) {
        if (kDebugMode) {
          print('error on listener $e $stack');
        }
      }));
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error resolving image $e');
      }
      getPrecaching().remove(s.id);
      systemPreferences.activeDownloads--;
      refresh();
      return;
    }
  }

  void clearCache() {
    for (var s in _src.values) {
      if (s.url.isNotEmpty && getImage(s.index) != null) {
        removeFromCache(s);
      }
    }
    _src.clear();
  }
}

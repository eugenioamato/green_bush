import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_bush/services/playback_state.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'package:pool/pool.dart';

import '../models/shot.dart';

class ImageRepository {
  late final Pool pool;
  final SystemPreferences systemPreferences;
  ImageRepository(
    this.systemPreferences,
  ) {
    pool = Pool(systemPreferences.maxDownloads,
        timeout: const Duration(seconds: 16));
  }

  final List<Shot> src = [];

  void removeFromCache(Shot s) {
    if (s.image != null) {
      s.image?.image.evict();
      s.image = null;
    }
  }

  Set<String> precaching = {};
  Set<String> getPrecaching() => precaching;

  void poolprecache(Shot s, PlaybackState playbackState) {
    pool.withResource(() => precache(s, playbackState));
  }

  void precache(Shot s, PlaybackState playbackState) {
    if (precaching.length > systemPreferences.maxDownloads) return;
    if (s.image != null) return;
    final url = s.url;
    if (url.isEmpty) return;
    if (playbackState.getDisableCaching()) {
      if (kDebugMode) {
        print('disabled precaching, stopped ${s.id}');
      }
      return;
    }

    if ((getPrecaching().contains(s.id))) return;

    getPrecaching().add(s.id);
    if (kDebugMode) {
      print('starting precache ${s.id}');
    }
    systemPreferences.activeThreads++;
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
      systemPreferences.activeThreads--;
      return;
    }

    try {
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((_, __) {
            if (kDebugMode) {
              final bytes =
                  PaintingBinding.instance.imageCache.currentSizeBytes;
              final maxbytes =
                  PaintingBinding.instance.imageCache.maximumSizeBytes;

              print(':: $bytes / $maxbytes');
            }
            getPrecaching().remove(s.id);
            if (kDebugMode) {
              print('ending    precache ${s.id} ${getPrecaching()} }');
            }
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
      systemPreferences.activeThreads--;
      return;
    }
    systemPreferences.activeThreads--;
    s.image = image;
  }

  void clearCache() {
    for (var s in src) {
      if (s.url.isNotEmpty) {
        removeFromCache(s);
      }
    }
    src.clear();
  }
}

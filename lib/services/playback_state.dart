import 'package:flutter/foundation.dart';
import 'package:green_bush/services/system_preferences.dart';
import 'image_repository.dart';

class PlaybackState {
  final ImageRepository r;
  final SystemPreferences p;
  PlaybackState(this.r, this.p);

  bool _complete = true;

  bool getComplete() => _complete;
  void setComplete(n) {
    _complete = n;
  }

  bool _auto = false;
  bool getAuto() => _auto;
  void setAuto(v) => _auto = v;

  double _loading = 0.0;
  double getLoading() => _loading;
  void setLoading(double rate) {
    if (kDebugMode) {
      print('setting load to $rate');
    }
    _loading = rate;
  }

  bool _disableCaching = false;
  void setDisableCaching(v) {
    _disableCaching = v;
  }

  bool getDisableCaching() => _disableCaching;

  int _autoDuration = 800;
  int getAutoDuration() => _autoDuration;
  void setAutoDuration(n) {
    if (n < 0 || n > 100000) return;
    _autoDuration = n;
  }

  int _page = 0;
  void setPage(int page, Function refresh) {
    var len = r.src.length;
    if (len == 0) {
      _page = 0;
      return;
    }
    int upLimit = page + p.getRange();
    if (upLimit > len) {
      upLimit = len;
    }

    for (int i = 0; i < len; i++) {
      if ((i < upLimit) &&
          ((i > (page - p.getRange())) ||
              ((p.getRange() + page > len) &&
                  (i < ((page + p.getRange()) % len))))) {
        r.poolprecache(r.src[i], this);
      } else {
        r.removeFromCache(r.src[(i)]);
      }
    }

    updateSecondarySlider();
    if (r.src[page].image == null) {
      if (getAuto()) {
        setAuto(false);
      }
    }
    _page = page;
    refresh();
  }

  int getPage() => _page;

  void updateSecondarySlider() {
    if (r.src.isEmpty) return;
    int k = getPage();
    int j = k;
    for (int i = getPage(); i < r.src.length; i++) {
      if (r.src[i].image == null) break;
      k++;
    }
    double result = k - 1.0;
    if (result != double.nan && result >= 0 && result <= r.src.length) {
      if (kDebugMode) {
        print('setting load to $result');
      }
      setLoading(result);
    }
    bool complete = true;
    for (int i = 0; i < j; i++) {
      if (r.src[i].image == null) {
        complete = false;
        break;
      }
    }
    if (complete) {
      setComplete(true);
    } else {
      setComplete(false);
    }
  }
}

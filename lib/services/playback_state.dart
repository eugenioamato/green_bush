import 'package:green_bush/services/system_preferences.dart';
import 'image_repository.dart';

class PlaybackState {
  final ImageRepository r;
  final SystemPreferences p;
  PlaybackState(this.r, this.p);

  bool _auto = false;
  bool getAuto() => _auto;
  void setAuto(v) => _auto = v;

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
    var len = r.getLen();
    if (len == 0) {
      _page = 0;
      return;
    }

    _page = page;

    refresh();
  }

  int getPage() => _page;

  sort() {
    setAuto(false);
    r.sort();
  }
}

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:green_bush/services/system_preferences.dart';

import 'package:green_bush/models/shot.dart';

Shot fakeShot(int index) => Shot('-1', '', '', '', 0, 0, 0, 0, 0, index);

class ImageRepository {
  final SystemPreferences systemPreferences;
  final Function refresh;
  ImageRepository(
    this.systemPreferences,
    this.refresh,
  );

  final SplayTreeSet<Shot> _src = SplayTreeSet<Shot>();

  Uint8List getBlob(int index) {
    final shot = getShot(index);
    return shot.blob;
  }

  void setBlob(int index, Uint8List blob) {
    final shot = getShot(index);
    if (shot.id != '-1') {
      shot.updateBlob(blob);
    }
  }

  Shot getShot(int index) {
    return _src.firstWhere((s) => s.index == index,
        orElse: () => fakeShot(index));
  }

  void addShot(int index, Shot s) {
    Shot r =
        _src.firstWhere((s) => s.index == index, orElse: () => fakeShot(index));
    if (r.id != '-1') {
      _src.remove(r);
    }
    _src.add(s);
  }

  int getLen() => _src.length;

  void clearCache() {
    _src.clear();
  }

  int loadedElementsLen() {
    return _src.where((element) => element.blob.isNotEmpty).length;
  }

  List<Shot> loadedElements() {
    final list = _src.where((element) => element.blob.isNotEmpty).toList();
    list.sort();
    return list;
  }
}

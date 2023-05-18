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

  final HashMap<int, Uint8List> _blob = HashMap<int, Uint8List>();
  final HashMap<int, Shot> _src = HashMap<int, Shot>();

  Uint8List getBlob(int page) =>
      _blob.containsKey(page) ? _blob[page]! : Uint8List(0);
  void setBlob(int index, Uint8List data) => _blob[index] = data;
  Shot getShot(int index) =>
      (_src.containsKey(index)) ? _src[index]! : fakeShot(index);
  void addShot(int index, Shot s) => _src[index] = s;

  int getLen() => _src.length;

  void clearCache() {
    for (int i = 0; i < _src.length; i++) {
      if (getBlob(i).isNotEmpty) {
        setBlob(i, Uint8List(0));
      }
    }
    _src.clear();
  }

  Iterable<int> loadedElements() {
    return List.generate(getLen(), (v) => v)
        .where((e) => getBlob(e).isNotEmpty);
  }
}

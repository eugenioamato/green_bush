import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:green_bush/services/system_preferences.dart';

import 'package:green_bush/models/shot.dart';
import 'package:image_compare/image_compare.dart';

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

  List<Shot> fittedElements() {
    return _src
        .where((element) =>
            element.blob.isNotEmpty && element.diff < double.infinity)
        .toList();
  }

  List<Shot> loadedElements() {
    final list = _src.where((element) => element.blob.isNotEmpty).toList();
    list.sort();
    return list;
  }

  void sort() async {
    if (_src.isEmpty) return;
    final nsrc = loadedElements();
    if (nsrc.length != _src.length) return;

    double k = 1.1;
    Uint8List blob = nsrc.first.blob;
    nsrc.first.diff = k;
    k = 1.16;
    nsrc.removeAt(0);

    do {
      int next = -1;
      double min = double.infinity;

      for (var i in nsrc) {
        var result = await compute(confront, Tuple(blob, i.blob));
        if (kDebugMode) {
          print('result:$result $i');
        }
        if (result < min) {
          min = result;
          next = i.index;
        }
        if (min < 0.05) break;
      }
      if (next < 0) return;
      getShot(next).updateDiff(k);
      k *= 1.16;
      nsrc.remove(getShot(next));
      blob = getBlob(next);
    } while (nsrc.isNotEmpty);

    refresh();
  }
}

confront(Tuple t) {
  return compareImages(
      src1: t.blob1, src2: t.blob2, algorithm: ChiSquareDistanceHistogram());
}

class Tuple {
  final Uint8List blob1;
  final Uint8List blob2;

  Tuple(this.blob1, this.blob2);
}

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

  void sort() async {
    if (_src.isEmpty) return;
    final nsrc=loadedElements().toList(growable: true);
    if (nsrc.length!=_src.length) return;
    final sorted=<int>[].toList(growable: true);

      Uint8List blob = getBlob(nsrc.first);
      nsrc.removeAt(0);
      sorted.add(0);

      do{
      int next = -1;
      double min = double.infinity;

      for (var i in nsrc.take(20)) {
        var result = (await compareImages(src1: blob,
            src2: getBlob(i),
            algorithm: ChiSquareDistanceHistogram())).abs();
        if (kDebugMode) {
          print('result:$result $i');
        }
        if (result < min) {
          min = result;
          next = i;
        }
        if (min<0.01) break;
      }
      if (next<0) return;
      sorted.add(next);
      nsrc.remove(next);
      blob = getBlob(next);
    } while(nsrc.isNotEmpty);

      if (kDebugMode) {
        print('sorted:\n $sorted');
      }
      final newSrc=<int,Shot>{};
      final newBlob=<int,Uint8List>{};
      int k=0;
      for (int i in sorted){
        newSrc[k]=getShot(i).copyWith(newIndex: k);
        newBlob[k]=getBlob(i);
        k++;
      }

      _src.addAll(newSrc);
      _blob.addAll(newBlob);
      refresh();
  }
}

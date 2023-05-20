import 'dart:io';
import 'dart:core';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<bool> saveFile(Uint8List data, String idd, String prompt,
      String nprompt, String extension) async {
    Directory directory = await getApplicationSupportDirectory();
    if (Platform.isWindows || Platform.isMacOS) {
      var dir = await getDownloadsDirectory();
      if (dir != null) {
        directory = dir;
      }
    } else if (Platform.isAndroid) {
      var dir = await getExternalStorageDirectory();
      if (dir != null) {
        directory = dir;
      }
    }

    String label = '$idd.$prompt.$nprompt ';
    String id = label
        .replaceAll(' ', '')
        .replaceAll(',', '_')
        .replaceAll('/', '')
        .replaceAll(':', '');
    id = id.substring(0, min(254, id.length) - (extension.length));

    try {
      final saveDir =
          Directory('${directory.path}${Platform.pathSeparator}GreenBush');
      bool hasExisted = await saveDir.exists();
      if (!hasExisted) {
        saveDir.create();
      }
      var path = '${saveDir.path}${Platform.pathSeparator}$id.$extension';

      final File file = File(path);
      await file.writeAsBytes(data);

      if (kDebugMode) {
        print('written file >> ${file.path}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error saving file $e');
      }
      return false;
    }

    return true;
  }
}

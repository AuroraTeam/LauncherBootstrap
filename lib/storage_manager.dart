import 'dart:io';

import 'package:launcher_bootstrap/config.dart';

class StorageManager {
  static final String wrapperDirectory =
      '${_getUserDirectory()}/${Config.projectDirectoryName}';

  static _getUserDirectory() {
    if (Platform.isWindows) {
      return Platform.environment['APPDATA'];
    } else {
      return Platform.environment['HOME'];
    }
  }
}

import 'dart:io';

import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherStarter {
  static startLauncher() async {
    print('Starting launcher...');

    await Process.start(
        await _resolveJavaExecutablePath(), ['-jar', 'launcher.jar'],
        mode: ProcessStartMode.detached,
        workingDirectory: StorageManager.wrapperDirectory);
  }

  static _resolveJavaExecutablePath() async {
    var javaDirectory =
        await Directory('${StorageManager.wrapperDirectory}/java').list().first;

    if (Platform.isMacOS) {
      return '${javaDirectory.path}/Contents/Home/bin/java';
    } else {
      return '${javaDirectory.path}/bin/java';
    }
  }
}

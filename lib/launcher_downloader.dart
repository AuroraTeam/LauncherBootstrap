import 'dart:io';

import 'package:http/http.dart';
import 'package:launcher_bootstrap/config.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherDownloader {
  static checkLauncher() async {
    print('Checking launcher...');

    final launcherFile =
        File('${StorageManager.wrapperDirectory}/launcher.jar');

    if (await launcherFile.exists()) {
      print('Launcher is already installed.');
      return;
    }

    print('Launcher is not installed. Downloading...');
    await _downloadLauncher(launcherFile);
  }

  static _downloadLauncher(File launcherFile) async {
    final launcherJar = await get(Config.launcherJarUrl);
    if (launcherJar.statusCode != 200) {
      print(
          'Failed to download launcher. Status code: ${launcherJar.statusCode}');
      return;
    }

    await launcherFile.writeAsBytes(launcherJar.bodyBytes);

    print('Launcher downloaded successfully.');
  }
}

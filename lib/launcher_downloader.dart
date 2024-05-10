import 'dart:io';

import 'package:http/http.dart';
import 'package:launcher_bootstrap/config.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherDownloader {
  static checkLauncher() async {
    print('Проверка лаунчера...');

    final launcherFile =
        File('${StorageManager.wrapperDirectory}/core.jar');

    if (await launcherFile.exists()) {
      print('Лаунчер уже установлен.');
      return;
    }

    print('Лаунчер не установлен. Выполняю загрузку...');
    await _downloadLauncher(launcherFile);
  }

  static _downloadLauncher(File launcherFile) async {
    final launcherJar = await get(Config.launcherJarUrl);
    if (launcherJar.statusCode != 200) {
      print(
          'Не удалось загрузить лаунчер. Код состояния: ${launcherJar.statusCode}');
      return;
    }

    await launcherFile.writeAsBytes(launcherJar.bodyBytes);

    print('Лаунчер успешно загружен.');
  }
}

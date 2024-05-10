import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class JavaDownloader {
  static checkJava() async {
    print('Проверка Java...');

    final javaDirectory = Directory('${StorageManager.wrapperDirectory}/java');

    if (await javaDirectory.exists()) {
      print('Java уже установлена.');
      return;
    }

    print('Java не установлена. Выполняю загрузку...');
    await _downloadJava(javaDirectory);
  }

  static _downloadJava(Directory javaDirectory) async {
    final javaLink = Uri.https(
      'api.azul.com',
      'metadata/v1/zulu/packages/',
      {'java_version': '22', 'os': _getOs(), 'arch': _getArch(), 'archive_type': _getExt(), 'java_package_type': 'jre', 'javafx_bundled': 'true', 'latest': 'true', 'release_status': 'ga', 'availability_types': 'CA', 'certifications': 'tck', 'page': '1', 'page_size': '1'}
    );
    final javaData = await get(javaLink);
    final body = json.decode(javaData.body);

    final javaZip = await get(Uri.parse(body[0]['download_url']));
    if (javaZip.statusCode != 200) {
      print('Не удалось загрузить Java. Код состояния: ${javaZip.statusCode}');
      return;
    }

    print('Извлечение Java...');
    await javaDirectory.create(recursive: true);

    Archive javaBinary;

    if (Platform.isWindows) {
      javaBinary = ZipDecoder().decodeBytes(javaZip.bodyBytes);
    } else {
      javaBinary = TarDecoder()
          .decodeBytes(GZipDecoder().decodeBytes(javaZip.bodyBytes));
    }

    for (final file in javaBinary) {
      if (file.isFile) {
        File('${javaDirectory.path}/${file.name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      }
    }
  }

  static _getOs() {
    return Platform.operatingSystem;
  }

  static _getArch() {
    switch (Abi.current()) {
      case Abi.linuxArm:
        return 'aarch32';

      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return 'i686';

      case Abi.linuxX64:
      case Abi.macosX64:
      case Abi.windowsX64:
        return 'x64';

      case Abi.linuxArm64:
      case Abi.macosArm64:
      case Abi.windowsArm64:
        return 'aarch64';
    }
  }

  static _getExt() {
    if (Platform.isWindows) {
      return 'zip';
    }
    return "tar.gz";
  }
}

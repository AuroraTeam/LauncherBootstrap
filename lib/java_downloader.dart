import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class JavaDownloader {
  static checkJava() async {
    print('Checking Java...');

    final javaDirectory = Directory('${StorageManager.wrapperDirectory}/java');

    if (await javaDirectory.exists()) {
      print('Java is already installed.');
      return;
    }

    print('Java is not installed. Downloading...');
    await _downloadJava(javaDirectory);
  }

  static _downloadJava(Directory javaDirectory) async {
    final downloadLink = Uri.https(
      'corretto.aws',
      'downloads/latest/amazon-corretto-8-${_getArch()}-${_getOs()}-jre.${_getExt()}',
    );

    final javaZip = await get(downloadLink);
    if (javaZip.statusCode != 200) {
      print('Failed to download Java. Status code: ${javaZip.statusCode}');
      return;
    }

    print('Extracting Java...');
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
    if (Platform.isMacOS) {
      return 'mac';
    }
    return Platform.operatingSystem;
  }

  static _getArch() {
    switch (Abi.current()) {
      case Abi.linuxArm:
        return 'arm';

      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return 'x86';

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

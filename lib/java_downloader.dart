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
    final javaDataLink = Uri.https(
      'api.adoptium.net',
      'v3/assets/latest/8/hotspot',
      {'architecture': _getArch(), 'image_type': 'jre', 'os': _getOs()},
    );

    final javaData = await get(javaDataLink);
    if (javaData.statusCode != 200) {
      print('Failed to download Java. Status code: ${javaData.statusCode}');
      return;
    }

    final data = jsonDecode(javaData.body);
    final downloadLink = data[0]['binary']['package']['link'];

    final javaZip = await get(Uri.parse(downloadLink));
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
}

import 'package:launcher_bootstrap/java_downloader.dart';
import 'package:launcher_bootstrap/launcher_downloader.dart';
import 'package:launcher_bootstrap/launcher_starter.dart';

class App {
  static run(List<String> arguments) async {
    await JavaDownloader.checkJava();
    await LauncherDownloader.checkLauncher();
    await LauncherStarter.startLauncher();
  }
}

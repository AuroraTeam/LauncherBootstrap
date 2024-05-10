import 'package:launcher_bootstrap/app.dart';

void main(List<String> arguments) {
  App.run(arguments);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          // use AppIcon to show your application icon
          child: AppIconImage(),
        ),
      ),
    );
  }
}

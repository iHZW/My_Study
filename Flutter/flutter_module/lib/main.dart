import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FlutterBoost.singleton.registerPageBuilders({
      // 'sample://firstPage': (pageName, params, _) => FirstRouteWidget(),
      // 'sample://secondPage': (pageName, params, _) => SecondRouteWidget(),
    });

    FlutterBoost.handleOnStartPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Boost example",
      builder: FlutterBoost.init(),
      home: Container(),
    );
  }
}

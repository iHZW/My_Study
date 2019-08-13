import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TestPage"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            FlutterBoost.singleton.closePageForContext(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          Text("Native jump Flutter Test"),
          FlatButton(
            child: Text("跳转全站导航!!!"),
            onPressed: () {
              Navigator.pushNamed(context, 'totalNavigationPage');
              // FlutterBoost.singleton
              //     .openPage('TotalNavigationPage', {}, animated: true);
            },
          ),
          ListTile(
            title: Text("你好啊!!!!"),
          )
        ],
      ),
    );
  }
}

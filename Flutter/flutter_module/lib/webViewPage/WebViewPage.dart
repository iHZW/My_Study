import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatefulWidget {
  final arguments;
  WebViewPage({Key key, this.arguments}) : super(key: key);

  _WebViewPageState createState() =>
      _WebViewPageState(arguments: this.arguments);
}

class _WebViewPageState extends State<WebViewPage> {
  final arguments;
  _WebViewPageState({this.arguments});

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "${arguments != null ? arguments["url"] : "https://www.baidu.com"}",
      appBar: AppBar(
        title: Text('${arguments != null ? arguments["title"] : "WebView"}'),
      ),
    );
  }
}

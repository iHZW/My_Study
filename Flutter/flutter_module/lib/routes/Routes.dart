import 'package:flutter/material.dart';
import '../TestPage.dart';
import '../TotalNavigationPage.dart';
import '../webViewPage/WebViewPage.dart';
import '../TestName.dart';
import '../TestNameTwo.dart';

final routes = {
  'testPage': (context) => TestPage(),
  'totalNavigationPage': (context) => TotalNavigationPage(),
  '/webViewPage': (context, {arguments}) => WebViewPage(arguments: arguments),
  'testName': (context) => TestNamePage(),
  'testNameTwo': (context) => TestNameTwoPage(),
};

// 固定写法
var onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];

  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};

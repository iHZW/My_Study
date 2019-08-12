import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class TotalNavigationPage extends StatefulWidget {
  TotalNavigationPage({Key key}) : super(key: key);

  _TotalNavigationPageState createState() => _TotalNavigationPageState();
}

class _TotalNavigationPageState extends State<TotalNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("全站导航"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            FlutterBoost.singleton.closePageForContext(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 240,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: 30.0,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Container(
                        color: Colors.blue,
                        height: 25.0,
                        width: 8.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "热门推荐",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemAllViewDemo("新股申购", "images/xgsg.png",
                          subImageUrl: "images/hot.png"),
                      ItemAllViewDemo("模拟炒股", "images/mncg.png",
                          subImageUrl: "images/hot.png"),
                      ItemAllViewDemo("决策工具", "images/jcgj.png",
                          subImageUrl: "images/hot.png"),
                      ItemViewDemo("猜涨跌", "images/czd.png"),
                      ItemViewDemo("授权兑换码", "images/sqmdh.png"),
                      ItemViewDemo("办卡赢权益", "images/bkyqy.png"),
                      ItemViewDemo("智能盯盘", "images/znxg.png"),
                      ItemViewDemo("资产配置", "images/zxg.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 140,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Container(
                        color: Colors.blue,
                        height: 25.0,
                        width: 8.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "股票",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("交易", "images/jy.png"),
                      ItemViewDemo("行情", "images/hq.png"),
                      ItemViewDemo("银证转账", "images/yzzz.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 140,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 25.0,
                      width: 8.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "理财",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("活期理财", "images/gg.png"),
                      ItemViewDemo("稳健理财", "images/czd.png"),
                      ItemViewDemo("基金理财", "images/jy.png"),
                      ItemViewDemo("理财服务", "images/zxg.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 240,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 25.0,
                      width: 8.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "业务办理",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("账户检测", "images/zhjc.png"),
                      ItemViewDemo("修改密码", "images/xgmm.png"),
                      ItemViewDemo("创业板开通", "images/cybkt.png"),
                      ItemViewDemo("一账通账户", "images/pysq.png"),
                      ItemViewDemo("更多业务", "images/gdyw.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 140,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 25.0,
                      width: 8.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "决策支持",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("智能选股", "images/znxg.png"),
                      ItemViewDemo("数据中心", "images/sjzx.png"),
                      ItemViewDemo("股市直播", "images/gszb.png"),
                      ItemViewDemo("买盘高手", "images/zxg.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 140,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 25.0,
                      width: 8.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "我的关注",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("自选股", "images/zxg.png"),
                      ItemViewDemo("我的圈子", "images/wgjc.png"),
                      ItemViewDemo("股友社区", "images/spgs.png"),
                      ItemViewDemo("我的积分", "images/wdjf.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
          Container(
            height: 140,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      color: Colors.blue,
                      height: 25.0,
                      width: 8.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "投资者园地",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    //mainAxisSpacing: 10.0, //垂直间距
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    // childAspectRatio: 1.0, //宽和高的比值
                    children: <Widget>[
                      ItemViewDemo("K线速成班", "images/czd.png"),
                      ItemViewDemo("投教园地", "images/kxds.png"),
                      ItemViewDemo("新人专区", "images/zhjc.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10.0,
            color: Colors.white10,
          ),
        ],
      ),
    );
  }
}

class ItemAllViewDemo extends StatelessWidget {
  String itemName;
  String imageUrl;
  String subImageUrl;
  ItemAllViewDemo(
    this.itemName,
    this.imageUrl, {
    Key key,
    this.subImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      splashColor: Colors.white,
      color: Colors.white,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Stack(
            children: <Widget>[
              Positioned(
                child: Container(
                  height: 60.0,
                  width: 70.0,
                ),
              ),
              Positioned(
                top: 15.0,
                left: 15.0,
                child: Image(
                  image: AssetImage(this.imageUrl),
                  height: 30.0,
                  width: 30.0,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10.0,
                right: 0,
                child: Image(
                  alignment: Alignment.topRight,
                  image: AssetImage(this.subImageUrl),
                  height: 15.0,
                  width: 26.0,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  this.itemName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                width: 10.0,
              )
            ],
          )
          // Container(
          //   // width: 65.0,
          //   alignment: Alignment.center,
          // child: Text(
          //   this.itemName,
          //   style: TextStyle(fontSize: 12.0),
          // ),
          // )
        ],
      ),
      onPressed: () {
        // Navigator.pushNamed(context, '/luckDetailPage');
        Navigator.pushNamed(context, '/webViewPage', arguments: {
          "title": this.itemName,
          "url":
              "https://m.stock.pingan.com/static/valueservice/servicesale/index.html",
        });
      },
    );
  }
}

// class ItemViewDemo extends StatelessWidget {
//   String itemName;
//   String imageUrl;
//   String subImageUrl;
//   ItemViewDemo(
//     this.itemName,
//     this.imageUrl, {
//     Key key,
//     this.subImageUrl,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FlatButton(
//       // elevation: 0,
//       splashColor: Colors.white,
//       color: Colors.white,
//       child: Column(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           SizedBox(
//             height: 10.0,
//           ),
//           Stack(
//             children: <Widget>[
//               Positioned(
//                 child: Container(
//                   height: 50.0,
//                   width: 60.0,
//                   // color: Colors.white10,
//                 ),
//               ),
//               Positioned(
//                 top: 10.0,
//                 left: 15.0,
//                 // child: Image(
//                 //   // image: AssetImage(this.imageUrl),
//                 //   image: ,
//                 //   height: 35.0,
//                 //   width: 35.0,
//                 //   fit: BoxFit.cover,
//                 // ),
//                 child: Image.asset(
//                   this.imageUrl,
//                   height: 35.0,
//                   width: 35.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),

//               // Positioned(
//               //   top: 0,
//               //   right: 0,
//               //   child: Image(
//               //     alignment: Alignment.topRight,
//               //     image: AssetImage(this.subImageUrl),
//               //     height: 10.0,
//               //     width: 20.0,
//               //     fit: BoxFit.cover,
//               //   ),
//               // ),
//             ],
//           ),
//           Container(
//             // width: 65.0,
//             alignment: Alignment.center,
//             child: Text(
//               this.itemName,
//               style: TextStyle(fontSize: 12.0),
//             ),
//           )
//         ],
//       ),
//       onPressed: () {
//         // Navigator.pushNamed(context, '/luckDetailPage');
//         Navigator.pushNamed(context, '/webViewPage', arguments: {
//           "title": this.itemName,
//           "url":
//               "https://m.stock.pingan.com/static/valueservice/servicesale/index.html",
//         });
//       },
//     );
//   }
// }

class ItemViewDemo extends StatelessWidget {
  String itemName;
  String imageUrl;
  String subImageUrl;
  ItemViewDemo(
    this.itemName,
    this.imageUrl, {
    Key key,
    this.subImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      splashColor: Colors.white,
      color: Colors.white,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Positioned(
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                    ),
                  ),
                  Positioned(
                    top: 15.0,
                    left: 15.0,
                    child: Image(
                      image: AssetImage(this.imageUrl),
                      height: 30.0,
                      width: 30.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  this.itemName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0),
                ),
              )
            ],
          )
          // Container(
          //   // width: 65.0,
          //   alignment: Alignment.center,
          // child: Text(
          //   this.itemName,
          //   style: TextStyle(fontSize: 12.0),
          // ),
          // )
        ],
      ),
      onPressed: () {
        // Navigator.pushNamed(context, '/luckDetailPage');

        if (this.itemName == "新股申购" ||
            this.itemName == "模拟炒股" ||
            this.itemName == "决策工具") {
          Navigator.pushNamed(context, '/luckDetailPage');
        } else {
          Navigator.pushNamed(context, '/webViewPage', arguments: {
            "title": this.itemName,
            "url":
                "https://m.stock.pingan.com/static/valueservice/servicesale/index.html",
          });
        }
      },
    );
  }
}

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Meals.dart';

class Restaurants extends StatefulWidget {
  Restaurants({Key key}) : super(key: key);

  @override
  _RestaurantsState createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> with SingleTickerProviderStateMixin {
  double width;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  int count = 0;
  List<String> ressNames = [];
  List<String> ressImages = [];
  List<int> ressId = [];
  List<bool> ressDelivery = [];
  final GlobalState _globalState = GlobalState.instance;
  String userId;
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
  GlobalKey<InnerDrawerState>();
  bool _onTapToClose = false;
  bool _swipe = true;
  bool _tapScaffold = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  InnerDrawerDirection _direction = InnerDrawerDirection.start;

  _RestaurantsState() {
    userIdSetter();
    initOrders();
    fetchRess();
    Meals.mealsIds.clear();
  }

  Future<void> userIdSetter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(GlobalState.GETUSERID, body: {
      'username': prefs.get('username')
    }).then((http.Response response) {
      _globalState.set('userId', json.decode(response.body)['userId']);
    });
  }

  Future<void> initOrders() async {
    print(userId.toString());
    http.post(GlobalState.TMPORDERSDELETE, body: {'userId': userId});
  }

  Future<void> fetchRess() async {
    await http.get(GlobalState.RESTAURANTS).then((http.Response response) {
      setState(() {
        count = json.decode(response.body)['count'];
        ressNames.clear();
        ressImages.clear();
        ressId.clear();
        ressDelivery.clear();
      });
      for (int i = 0; i < count; i++) {
        ressNames.add(json.decode(response.body)['ressNames'][i]);
        ressImages.add(json.decode(response.body)['ressImages'][i]);
        ressId.add(json.decode(response.body)['ressId'][i]);
        ressDelivery.add(json.decode(response.body)['ressDelivery'][i]);
      }
    });
  }

  Future<void> logOutBtn() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('token', null);
    Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route <dynamic> route) => false);
  }

  void logOutConfirm(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Text('هل تريد تسجيل الخروج؟')
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("لا"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: new Text("نعم"),
              onPressed: logOutBtn,
            ),
          ],
        );
      },
    );
  }

  void resBtn(int resId, bool hasDeliveryService) {
    _globalState.set('resId', resId);
    _globalState.set('hasDeliveryService', hasDeliveryService);
    Navigator.of(context).pushNamed('/cats');
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchRess();
    _refreshController.refreshCompleted();
  }

  Widget _header(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
      child: Container(
          height: 100,
          width: width,
          decoration: BoxDecoration(
            color: Color(0xffFFFF00),
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                  top: 10,
                  right: -120,
                  child: _circularContainer(300, Color(0xffFFFF00))),
              Positioned(
                  top: -60,
                  left: -65,
                  child: _circularContainer(width * .5, Color(0xffFFFF00))),
              Positioned(
                  top: -230,
                  right: -30,
                  child: _circularContainer(width * .7, Colors.transparent,
                      borderColor: Color(0xff020244))),
              Positioned(
                  top: 50,
                  left: 0,
                  child: Container(
                      width: width,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "المطاعم",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: width * 4.8780487804878048780487804878049 / 100,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ))),
              Positioned(
                top: 55,
                right: 12,
                child: InkWell(
                  onTap: () => _innerDrawerKey.currentState.toggle(),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.menu, color: Color(0xff020244), size: 30),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget _circularContainer(double height, Color color, {Color borderColor = Colors.transparent, double borderWidth = 2}) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Meals.mealsIds.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var _width = MediaQuery.of(context).size.width / 2;
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: _onTapToClose,
      tapScaffoldEnabled: _tapScaffold,
      offset: IDOffset.horizontal(_offset),
      swipe: _swipe,
      boxShadow: _direction == InnerDrawerDirection.start &&
          _animationType == InnerDrawerAnimation.linear
          ? []
          : null,
      colorTransition: Color(0xffFFFF00),
      rightAnimationType: InnerDrawerAnimation.quadratic,

      rightChild: Material(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(width: 1, color: Colors.grey[200]),
                  right: BorderSide(width: 1, color: Colors.grey[200])),
            ),
            child: Column(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Container(
                  height: 100,
                  width: width,
                  color: Color(0xffFFFF00),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('/myorders');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              size: 25,
                              color: Color(0xff555555),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'طلباتي',
                              style: TextStyle(
                                fontSize: width * 4.8780487804878048780487804878049 / 100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed('/about'),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.info_outline,
                              size: 25,
                              color: Color(0xff555555),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'حول التطبيق',
                              style: TextStyle(
                                fontSize: width * 4.8780487804878048780487804878049 / 100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: logOutConfirm,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.exit_to_app,
                              size: 25,
                              color: Color(0xff555555),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'تسجيل خروج',
                              style: TextStyle(
                                fontSize: width * 4.8780487804878048780487804878049 / 100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),

      scaffold: Scaffold(
          backgroundColor: Colors.grey[200],
          body: Stack(
            children: <Widget>[
              SmartRefresher(
                enablePullDown: true,
                header: WaterDropMaterialHeader(
                  backgroundColor: Color(0xffFFFF00),
                  color: Color(0xff020244),
                  offset: 95,
                  distance: 100,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 100),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: count,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => resBtn(ressId[index], ressDelivery[index]),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                        ),
                                        child: Container(
                                          width: _width,
                                          height: _width - 50,
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            child: FadeInImage(
                                              image: NetworkImage(
                                                  '${GlobalState.RESIMAGES + ressImages[index]}'),
                                              fit: BoxFit.cover,
                                              placeholder: AssetImage(
                                                  'assets/loading.gif'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ressNames[index],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _header(context)
            ],
          )
      ),

    );
  }
}

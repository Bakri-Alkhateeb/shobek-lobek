import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrders extends StatefulWidget {
  MyOrders({Key key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> with SingleTickerProviderStateMixin {

  double width;
  int count = 0;
  String userId;
  List <String> ordersDates = [];
  List <String> ordersTimes = [];
  List <int> ordersIds = [];
  final GlobalState _globalState = GlobalState.instance;
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  bool _onTapToClose = false;
  bool _swipe = true;
  bool _tapScaffold = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  InnerDrawerDirection _direction = InnerDrawerDirection.start;
  bool noOrders = true;

  _MyOrdersState(){
    fetchMyOrders();
  }

  Future<void> fetchMyOrders() async{
    userId = _globalState.get('userId').toString();
    print(userId);
    http.post(GlobalState.MYORDERS, body: {
      'userId': userId,
    }).then((http.Response response){
      setState(() {
        count = json.decode(response.body)['ordersArrayLength'];
        ordersDates = [];
        ordersTimes = [];
      });
      for(int i = 0; i < count; i++){
        ordersDates.add(json.decode(response.body)['myOrders'][i]['orderdate']);
        ordersTimes.add(json.decode(response.body)['myOrders'][i]['ordertime']);
        ordersIds.add(json.decode(response.body)['myOrders'][i]['id']);
      }
      if(ordersIds.length == 0){
        setState(() {
          noOrders = true;
        });
      } else{
        setState(() {
          noOrders = false;
        });
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

  void single(int id){
    _globalState.set('orderId', id);
    Navigator.of(context).pushNamed('/single');
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
                  child: _circularContainer(300, Color(0xffFFFF00))
              ),
              Positioned(
                  top: -60,
                  left: -65,
                  child: _circularContainer(width * .5, Color(0xffFFFF00))
              ),
              Positioned(
                  top: -230,
                  right: -30,
                  child: _circularContainer(
                      width * .7, Colors.transparent,
                      borderColor: Color(0xff020244))
              ),
              Positioned(
                  top: 50,
                  left: 0,
                  child: Container(
                      width: width,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () =>  Navigator.of(context).pop(context),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: Color(0xff020244),
                              size: 30,
                            ),
                          ),
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "طلباتي",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: width * 4.8780487804878048780487804878049 / 100,
                                    fontWeight: FontWeight.bold),
                              )
                          )
                        ],
                      )
                  )
              ),
              Positioned(
                top: 50,
                right: 12,
                child: InkWell(
                  onTap: () => _innerDrawerKey.currentState.toggle(),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                          Icons.menu,
                          color: Color(0xff020244),
                          size: 30
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  Widget _circularContainer(double height, Color color,{Color borderColor = Colors.transparent, double borderWidth = 2}) {
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
    userId = _globalState.get('userId').toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: _onTapToClose,
      tapScaffoldEnabled: _tapScaffold,
      offset: IDOffset.horizontal(_offset),
      swipe: _swipe,
      boxShadow: _direction == InnerDrawerDirection.start && _animationType == InnerDrawerAnimation.linear ? [] : null,
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
                        Navigator.of(context).pushNamed('/one');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.restaurant_menu,
                              size: 25,
                              color: Color(0xff555555),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'المطاعم',
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
              Stack(
                children: <Widget>[
                  noOrders ? Center(
                    child: Container(
                      child: Text(
                        'لم تطلب شيئاً بعد',
                        style: TextStyle(
                          color: Color(0xffAAAAAA),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ) : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        SizedBox(height: 100),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: count,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => single(ordersIds[index]),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 55,
                                      height: 55,
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xff020244),
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 35,
                                          color: Color(0xffFFFF00),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      ordersDates[index],
                                      style: TextStyle(
                                          fontSize: 17
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'الساعة',
                                      style: TextStyle(
                                          fontSize: 17
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      ordersTimes[index],
                                      style: TextStyle(
                                          fontSize: 17
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
              _header(context)
            ],
          )
      ),

    );
  }
}
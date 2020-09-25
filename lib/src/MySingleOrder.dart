import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySingleOrder extends StatefulWidget {
  MySingleOrder({Key key}) : super(key: key);

  @override
  _MySingleOrderState createState() => _MySingleOrderState();
}

class _MySingleOrderState extends State<MySingleOrder> with SingleTickerProviderStateMixin {

  double width;
  int mealsCount = 0;
  String userId;
  final GlobalState _globalState = GlobalState.instance;
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  bool _onTapToClose = false;
  bool _swipe = true;
  bool _tapScaffold = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  InnerDrawerDirection _direction = InnerDrawerDirection.start;
  int orderId;
  List<int> ordersMealsIds;
  List<dynamic> ordersQuantities;
  List<String> orderMealsNames;
  List<String> orderMealsImages;
  List<dynamic> orderMealsPrices;
  int resId;
  String resName;
  int orderPrice;

  _MySingleOrderState(){
    fetchSingleOrder();
  }

  Future<void> fetchSingleOrder() async{
    orderId = _globalState.get('orderId');
    http.post(GlobalState.MYSINGLEORDER, body: {
      'orderId': orderId.toString()
    }).then((http.Response response){
      setState(() {
        ordersQuantities = json.decode(response.body)['mealsQuantities'];
        orderMealsPrices = json.decode(response.body)['singleMealPrices'];
        resId = json.decode(response.body)['mealsArray'][0]['refresid'];
        orderPrice = json.decode(response.body)['orderPrice'];
        mealsCount = json.decode(response.body)['mealsArrayLength'];
        _globalState.set('resId', resId);
      });
      for(int i = 0; i < mealsCount; i++){
        ordersMealsIds.add(json.decode(response.body)['mealsArray'][i]['id']);
        orderMealsNames.add(json.decode(response.body)['mealsArray'][i]['name']);
        orderMealsImages.add(json.decode(response.body)['mealsArray'][i]['image']);
      }
      http.post(GlobalState.FETCHRESNAME, body: {
        'resId': resId.toString()
      }).then((http.Response response){
        setState(() {
          resName = json.decode(response.body)['resName'];
        });
      });
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

  @override
  void initState() {
    super.initState();
    userId = _globalState.get('userId').toString();
    ordersMealsIds = [];
    ordersQuantities = [];
    orderMealsNames = [];
    orderMealsImages = [];
    orderMealsPrices = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _card(String imgPath) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image(
          image: NetworkImage('${GlobalState.MEALSIMAGES + imgPath}'),
          fit: BoxFit.fill,
        ),
      ),
      height: 75,
      width: 75,
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                offset: Offset(0, 5),
                blurRadius: 10,
                color: Color(0x12000000)
            )
          ]
      ),
    );
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
                                "محتويات الطلبية",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: 23,
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
                                fontSize: 20,
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
                                fontSize: 20,
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
                                fontSize: 20,
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
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        SizedBox(height: 100),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: mealsCount,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                width: width - 20,
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: _card(orderMealsImages[index]),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height: 100,
                                        child: Column(
                                          textDirection: TextDirection.rtl,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 15),
                                            Container(
                                              child: Row(
                                                textDirection: TextDirection.rtl,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      orderMealsNames[index],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold)
                                                  ),
                                                  SizedBox(width: 10)
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              children: <Widget>[
                                                SizedBox(width: 5),
                                                Text(
                                                    orderMealsPrices[index].toString(),
                                                    style: TextStyle(
                                                        fontSize: 12, color: Colors.black)
                                                ),
                                                SizedBox(width: 3),
                                                Text('ل.س',
                                                    style: TextStyle(
                                                        fontSize: 12, color: Colors.black)
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: TextField(
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              enableInteractiveSelection: false,
                                              textAlignVertical: TextAlignVertical.bottom,
                                              expands: false,
                                              enabled: false,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  filled: false,
                                                  hintText: '${ordersQuantities[index]}',
                                                  hintStyle: TextStyle(
                                                      color: Color(0xff020244)
                                                  )
                                              )
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _header(context),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        Container(
                          color: Color(0xffFFFF00),
                          width: width / 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            textDirection: TextDirection.rtl,
                            children: <Widget>[
                              Container(
                                height: 50,
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      ':من مطعم',
                                      style: TextStyle(
                                          fontSize: width * 4.8780487804878048780487804878049 / 100,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff020244)
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Text(
                                      '${resName}',
                                      style: TextStyle(
                                          fontSize: width * 4.8780487804878048780487804878049 / 100,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff020244)
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          thickness: 2,
                          color: Color(0xff020244),
                          width: 0,
                        ),
                        Container(
                          color: Color(0xffFFFF00),
                          width: width / 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            textDirection: TextDirection.rtl,
                            children: <Widget>[
                              Container(
                                height: 50,
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      ':المجموع',
                                      style: TextStyle(
                                          fontSize: width * 4.8780487804878048780487804878049 / 100,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff020244)
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Text(
                                      '${orderPrice}',
                                      style: TextStyle(
                                          fontSize: width * 4.8780487804878048780487804878049 / 100,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff020244)
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Text('ل.س',
                                        style: TextStyle(
                                            fontSize: width * 4.8780487804878048780487804878049 / 100,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff020244)
                                        )
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              )
            ],
          )
      ),
    );
  }
}
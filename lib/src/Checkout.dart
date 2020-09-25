import 'dart:async';
import 'dart:ui';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Checkout extends StatefulWidget {
  Checkout({Key key}) : super(key: key);

  static Map<int ,int> mealsQuantities = <int, int>{};

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> with SingleTickerProviderStateMixin {

  GlobalState _globalState = GlobalState.instance;
  double width;
  String userId;
  List<int> mealsIds = [];
  List<int> mealsTimes = [];
  List<int> queuesIds = [];
  List<String> mealsNames = [];
  List<int> mealsPrices = [];
  List<String> mealsImages = [];
  int count;
  int totalPrice;
  int totalTime;
  List<int> keys = Checkout.mealsQuantities.keys.toList();
  int length;
  List<int> myValues;

  _CheckoutState(){
    userIdSetter();
  }

  @override
  void initState() {
    super.initState();
    myValues = [];
    keys.sort();
    length = keys.length;
    totalPrice = 0;
    totalTime = 0;
    mealsIds = _globalState.get('mealsIds');
    mealsNames = _globalState.get('mealsNames');
    mealsPrices = _globalState.get('mealsPrices');
    mealsImages = _globalState.get('mealsImages');
    mealsTimes = _globalState.get('mealsTimes');
    queuesIds = _globalState.get('queuesIds');
    count = mealsIds.length;
    calcSum();
    quan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void quan(){
    for(int i = 0; i < length; i++){
      setState(() {
        myValues.add(Checkout.mealsQuantities[keys[i]]);
      });
    }
    _globalState.set('quanValues', myValues);
  }

  Future<void> addQuantities() async{
    http.patch(GlobalState.MYORDERS, body: {
      'userId': userId,
      'quantities': myValues.toString()
    });
  }

  Future<void> userIdSetter() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = (prefs.getInt('userId')).toString();
    });
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
                                "الطلبية",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: width * 4.8780487804878048780487804878049 / 100,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      )
                  )
              ),
            ],
          )
      ),
    );
  }

  void calcSum(){
    int sum = 0;
    int time = 0;
    for(int i = 0; i < count; i++){
      sum += Checkout.mealsQuantities[mealsIds[i]] * mealsPrices[i];
      time += Checkout.mealsQuantities[mealsIds[i]] * mealsTimes[i];
    }
    setState(() {
      totalPrice = sum;
      totalTime = time;
    });
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

  Widget _foodList(int mealId, String mealName, int mealPrice, String mealImage, BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Container(
          height: 100,
          child: _foodInfo(mealId, mealName, mealPrice, mealImage, context),
        ),
      ],
    );
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

  Widget _foodInfo(int id, String name, int price, String image, BuildContext context) {
    return Container(
      height: 170,
      width: width - 20,
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: _card(image),
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
                            name,
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
                          price.toString(),
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
                        hintText: '${Checkout.mealsQuantities[id]}',
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
    );
  }

  void nextBtn(){
    _globalState.set('totalPrice', totalPrice);
    _globalState.set('totalTime', totalTime);
    _globalState.set('queuesIds', queuesIds);
    addQuantities();
    Navigator.of(context).pushNamed('/nextcheckout');
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Stack(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.only(top: 100, bottom: 50),
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return _foodList(
                      mealsIds[index],
                      mealsNames[index],
                      mealsPrices[index],
                      mealsImages[index],
                      context
                  );
                }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        textDirection: TextDirection.rtl,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFFFF00),
                              border: Border(
                                left: BorderSide(width: 1.0, color: Color(0xff020244)),
                              ),
                            ),
                            height: 50,
                            width: width / 2,
                            child: Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 15,),
                                Text(
                                  ":المجموع",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff020244)
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  totalPrice.toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff020244)
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  "ل.س",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff020244)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      RaisedButton(
                        color: Color(0xffFFFF00),
                        onPressed: nextBtn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          textDirection: TextDirection.rtl,
                          children: <Widget>[
                            Container(
                              width: width / 2 - 32,
                              height: 50,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'متابعة',
                                    style: TextStyle(
                                        fontSize: width * 4.8780487804878048780487804878049 / 100,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff020244)
                                    ),
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
    );
  }
}
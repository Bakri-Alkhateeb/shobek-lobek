import 'dart:ui';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Checkout.dart';
import 'Meals.dart';
import 'NextCheckout.dart';

class Cart extends StatefulWidget {
  Cart({Key key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {

  GlobalState _globalState = GlobalState.instance;
  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  double width;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  String userId;
  List<int> mealsIds = [];
  List<int> mealsTimes = [];
  List<int> queuesIds = [];
  List<String> mealsNames = [];
  List<int> mealsPrices = [];
  List<String> mealsImages = [];
  int count;
  bool isCartEmpty = true;
  final _formKey = GlobalKey<FormState>();

  _CartState(){
    mealsIds = Meals.mealsIds;
    count = mealsIds.length;
    userIdSetter();
    fetchCart();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> userIdSetter() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = (prefs.getInt('userId')).toString();
    });
  }

  Future<void> _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 1000));

    fetchCart();

    _refreshController.refreshCompleted();
  }

  Future<void> fetchCart() async{
    await Future.forEach(mealsIds, (id){
      http.post(GlobalState.FETCHCART, body: {
        'mealId': id.toString()
      }).then((http.Response response){
        setState(() {
          _globalState.set('orderId', json.decode(response.body)['orderId']);
          isCartEmpty = false;
        });
        mealsTimes.add(json.decode(response.body)['mealTime']);
        mealsNames.add(json.decode(response.body)['mealName']);
        mealsPrices.add(json.decode(response.body)['mealPrice']);
        mealsImages.add(json.decode(response.body)['mealImage']);
        if(!queuesIds.contains(json.decode(response.body)['mealQueue'])){
          if(queuesIds.isNotEmpty){
            NextCheckout.areQueuesTheSame = false;
          }
          queuesIds.add(json.decode(response.body)['mealQueue']);
        }
        _globalState.set('mealsIds', mealsIds);
        _globalState.set('mealsNames', mealsNames);
        _globalState.set('mealsPrices', mealsPrices);
        _globalState.set('mealsImages', mealsImages);
        _globalState.set('mealsTimes', mealsTimes);
        _globalState.set('queuesIds', queuesIds);
      });
    });
    setArraysValues();
    Future.delayed(Duration(milliseconds: 2000));
  }

  Widget _header(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)
      ),
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
                            onTap: (){
                              Navigator.of(context).pop(context);
                            },
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: Color(0xff020244),
                              size: 30,
                            ),
                          ),
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "حدد الكميات",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: width * 4.8780487804878048780487804878049 / 100,
                                    fontWeight: FontWeight.bold
                                ),
                              ))
                        ],
                      )
                  )
              ),
              Positioned(
                top: 50,
                right: 12,
                child: InkWell(
                  onTap: emptyCartBtn,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.delete,
                          color: Color(0xff020244),
                          size: 25
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

  Future<void> logOutBtn() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('token', null);
    emptyCartBtn();
    Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route <dynamic> route) => false);
  }

  Future<void> dismissObject(int id, String name, int price, String image) async{
    count--;
    mealsIds.remove(id);
    mealsNames.remove(name);
    mealsPrices.remove(price);
    mealsImages.remove(image);
    debugPrint('Dismissed');
    setArraysValues();
    if(count == 0){
      setState(() {
        count = 0;
      });
      emptyCartBtn();
    }
    print(mealsIds.toString());
    http.patch(GlobalState.TMPORDERS, body: {
      'userId': userId,
      'mealsIds': mealsIds.toString()
    });
  }

  void setArraysValues(){
    _globalState.set('mealsIds', mealsIds);
    _globalState.set('mealsNames', mealsNames);
    _globalState.set('mealsPrices', mealsPrices);
    _globalState.set('mealsImages', mealsImages);
  }

  void emptyCartBtn(){
    mealsIds = [];
    mealsNames = [];
    mealsPrices = [];
    mealsImages = [];
    setArraysValues();
    http.post(GlobalState.TMPORDERSDELETE, body: {
      'userId': userId
    });
    setState(() {
      isCartEmpty = true;
    });
    Navigator.of(context).pushNamedAndRemoveUntil('/one',(Route <dynamic> route) => false);
  }

  void nextBtn(){
    if (_formKey.currentState.validate()) {
      http.post(GlobalState.ORDERSINSERT, body: {
        'mealsIds': Meals.mealsIds.toString(),
        'userId': userId
      }).then((http.Response response){
        if (response.statusCode == 201){
          Navigator.of(context).pushNamed('/checkout');
        }
      });
    }
    else{
      setState(() {
        scaffoldState.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xffFFFF00),
              content: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'الرجاء إدخال جميع الكميات',
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff020244)
                    ),
                  ),
                ],
              ),
            )
        );
      });
    }
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
          width: width,
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
          image: NetworkImage('${GlobalState.MEALSIMAGES + imgPath.toString()}'),
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
      margin: EdgeInsets.only(left: 15, right: 15),
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
                              fontSize: 12,
                              color: Colors.black
                          )
                      ),
                      SizedBox(width: 3),
                      Text('ل.س',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black
                          )
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
                height: 60,
                child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (text){
                      Checkout.mealsQuantities[id] = int.parse(text);
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enableInteractiveSelection: false,
                    expands: false,
                    enabled: true,
                    maxLength: 2,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: false,
                        hintText: '',
                        counterText: 'العدد',
                        counterStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold
                        ),
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: scaffoldState,
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
                child: isCartEmpty ? Center(
                  child: Container(
                    child: Text(
                      'انتظر قليلاً',
                      style: TextStyle(
                        color: Color(0xffAAAAAA),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ) : Form(
                  key: _formKey,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 100, bottom: 50),
                      itemCount: count,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                            direction: DismissDirection.startToEnd,
                            onDismissed: (DismissDirection direction){
                              dismissObject(mealsIds[index], mealsNames[index], mealsPrices[index], mealsImages[index]);
                            },
                            key: Key(mealsIds[index].toString()),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                              ),
                              child: Row(
                                textDirection: TextDirection.ltr,
                                children: <Widget>[
                                  SizedBox(width: 15,),
                                  Icon(
                                    Icons.delete,
                                    color: Color(0xffffffff),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            child: _foodList(
                                mealsIds[index],
                                mealsNames[index],
                                mealsPrices[index],
                                mealsImages[index],
                                context
                            )
                        );
                      }
                  ),
                )
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
                      RaisedButton(
                        color: Color(0xffFFFF00),
                        onPressed: nextBtn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          textDirection: TextDirection.rtl,
                          children: <Widget>[
                            Container(
                              width: width - 32,
                              height: 50,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'معاينة الطلبية',
                                    style: TextStyle(
                                        fontSize: width * 4.8780487804878048780487804878049 / 100,
                                        color: Color(0xff020244),
                                        fontWeight: FontWeight.bold
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
import 'dart:ui';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:shobek_lobek/src/Widget/mealCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Meals extends StatefulWidget {

  static  List<int> mealsIds = [];

  Meals({Key key}) : super(key: key);

  @override
  _MealsState createState() => _MealsState();
}

class _MealsState extends State<Meals> with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  double width;
  int mealsCount = 0;
  List <String> mealsNames = [];
  List <String> mealsImages = [];
  List <int> mealsId = [];
  List <int> mealsTimes = [];
  List <String> mealsDesc = [];
  List <String> mealsPrice = [];
  String userId;
  final GlobalState _globalState = GlobalState.instance;
  bool isMealsIdsEmpty = true;
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  bool _onTapToClose = false;
  bool _swipe = true;
  bool _tapScaffold = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  InnerDrawerDirection _direction = InnerDrawerDirection.start;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _MealsState() {
    userIdSetter();
    fetchMeals();
  }

  Future<void> userIdSetter() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = (prefs.getInt('userId')).toString();
    });
  }

  Future<void> _addBtn(String userId2) async{
    Meals.mealsIds.sort();
    if(!MealCard.isMealsIdsEmpty){
      Navigator.of(context).pushNamed('/cart');
    } else{
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
                    'الرجاء اختيار وجبة واحدة على الأقل',
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

  Future<void> fetchMeals() async{
    await http.post(GlobalState.MEALS, body: {
      'resId': _globalState.get('resId').toString(),
      'catId': _globalState.get('catId').toString(),
    }).then((http.Response response){
      setState(() {
        mealsCount = json.decode(response.body)['count'];
        mealsNames.clear();
        mealsImages.clear();
        mealsId.clear();
        mealsDesc.clear();
        mealsPrice.clear();
      });
      for(int i = 0; i < mealsCount; i++){
        mealsNames.add(json.decode(response.body)['mealsNames'][i]);
        mealsImages.add(json.decode(response.body)['mealsImages'][i]);
        mealsId.add(json.decode(response.body)['mealsId'][i]);
        mealsTimes.add(json.decode(response.body)['mealsTimes'][i]);
        mealsDesc.add(json.decode(response.body)['mealsDesc'][i]);
        mealsPrice.add(json.decode(response.body)['mealsPrice'][i].toString());
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

  Future<void> _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchMeals();
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
                                _globalState.get('catName').toString(),
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: width * 4.8780487804878048780487804878049 / 100,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      )
                  )
              ),
              Positioned(
                top: 55,
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
                            itemCount: mealsCount,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2
                            ),
                            itemBuilder: (context, index) {
                              return MealCard(
                                  mealsId[index],
                                  mealsNames[index],
                                  mealsPrice[index].toString(),
                                  mealsDesc[index],
                                  '${GlobalState.MEALSIMAGES + mealsImages[index]}',
                                  index
                              );
                            },
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
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
                          disabledColor: Color(0xffffffff).withOpacity(0),
                          color: Color(0xffFFFF00),
                          onPressed: () => _addBtn(userId),
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
                                      'التالي',
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
      ),
    );
  }
}
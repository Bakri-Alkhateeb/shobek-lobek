import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class About extends StatefulWidget {
  About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> with SingleTickerProviderStateMixin {
  double width;
  int count = 0;
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();
  bool _onTapToClose = false;
  bool _swipe = true;
  bool _tapScaffold = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  InnerDrawerDirection _direction = InnerDrawerDirection.start;
  String currentYear = Jiffy().format('y');

  Future<void> logOutBtn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('token', null);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
  }

  void logOutConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[Text('هل تريد تسجيل الخروج؟')],
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
  }

  @override
  void dispose() {
    super.dispose();
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
                          InkWell(
                            onTap: () => Navigator.of(context).pop(context),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: Color(0xff020244),
                              size: 30,
                            ),
                          ),
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "حول التطبيق",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ))),
              Positioned(
                top: 50,
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
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    print(width.toString());
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  SizedBox(height: 110),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        textDirection: TextDirection.rtl,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                        spreadRadius: 5
                                    )
                                  ]
                              ),
                              height: MediaQuery.of(context).size.height - 145,
                              alignment: AlignmentDirectional.topStart,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: width - 32,
                                      child: Text(
                                        ':عزيزي المستخدم, يتيح لك هذا التطبيق',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: width * 0.038,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.طلب الطعام عن طريق الانترنت',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.إظهار أسعار و مواصفات و مكونات الاطعمة',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.إمكانية تحديد زمن معين لاستلام الطلب',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.إخبارك بالوقت المتوقع لاستلام طلبك إن لم تحدد وقتاً معيناً',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.تخزين طلباتك لإمكانية مراجعتها لاحقاً',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      width: width - 32,
                                      child: Text(
                                        ':طريقة استخدام التطبيق',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: width * 0.038,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.اختر مطعماً من قائمة المطاعم',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.اختر صنف أو نوع الوجبة التي ستطلبها',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.اختر الوجبات التي تريدها من قائمة الوجبات',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'إن كنت تريد إضافة وجبات أخرى من صنف آخر يمكنك ذلك',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.عن طريق الرجوع إلى قائمة التصنيفات ثم اختيار صنف آخر',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.انتقل إلى صفحة الطلبية عن طريق الضغط على زر التالي',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '.حدد كميات الوجبات التي طلبتها',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'في حال أردت حذف وجبة من الطلبية يمكنك ذلك عن طريق',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.سحبها إلى اليمين',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'اضغط على معاينة الطلبية لتظهر لك صفحة تحوي المعلومات',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.التي ستطلبها',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'اضغط على متابعة لتنتقل إلى صفحة تحدد فيها موعداً',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'لاستلام الطلبية إن أردت ذلك, في حال لم ترد تحديد موعد',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.اترك الخيار كما هو',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'كما يمكنك اختيار فيما إذا كنت ستحضر الطلبية بنفسك أم',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.تريد من خدمة التوصيل أن توصلها لك',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'في حال اخترت أن يتم توصيل الطلبية من قبل خدمة',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'التوصيل سيترتب عليك اختيار المكان الذي تريد أن توصل',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.إليه الطلبية',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'اضغط على إرسال و ستظهر لك نافذة تخبرك بالوقت المتوقع',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '.لتوصيل طلبيتك أو لانتهائها في حال كنت ستحضرها بنفسك',
                                            style: TextStyle(
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Divider(
                                        color: Color(0xff020244),
                                        thickness: 2,
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Text(
                                        'جميع الحقوق محفوظة للمطور © ${currentYear}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Text(
                                        ':تم بناء هذا التطبيق من قبل المطور',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: width - 32,
                                      child: Text(
                                        'بكري الخطيب',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                  ],
                                ),
                              )
                          )
                        ],
                      ))
                ],
              ),
              _header(context),
            ],
          )
      ),
    );
  }
}

/*
Column(
                              children: <Widget>[
                                Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: <Widget>[

                                SizedBox(height: 5,),

                                SizedBox(height: 5,),

                                SizedBox(height: 5,),

                                Expanded(
                                  child: Column(
                                    textDirection: TextDirection.rtl,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[

                                      Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(

                                            style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5,),
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[

                                        ],
                                      ),
                                      SizedBox(height: 20,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
*/

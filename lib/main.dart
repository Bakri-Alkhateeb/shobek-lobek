import 'package:shobek_lobek/functions/globalState.dart';
import 'package:shobek_lobek/src/About.dart';
import 'package:shobek_lobek/src/Categories.dart';
import 'package:shobek_lobek/src/Checkout.dart';
import 'package:shobek_lobek/src/LoginPage.dart';
import 'package:shobek_lobek/src/Meals.dart';
import 'package:shobek_lobek/src/MyOrders.dart';
import 'package:shobek_lobek/src/MySingleOrder.dart';
import 'package:shobek_lobek/src/SignUpPage.dart';
import 'package:shobek_lobek/src/SuccesfulLogInPage.dart';
import 'package:shobek_lobek/src/NextCheckout.dart';
import 'package:shobek_lobek/src/Widget/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/welcomePage.dart';
import 'package:shobek_lobek/src/Restaurants.dart';
import 'package:shobek_lobek/src/Cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {

    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isConnected = false;
  GlobalState _globalState = GlobalState.instance;
  @override
  void initState() {
    auth();
    super.initState();
  }

  void auth() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if(token != null){
      final String username = prefs.getString('username');
      final String password = prefs.getString('password');
      final String userId = prefs.getInt('userId').toString();
      isLoggedIn = true;
    }
    http.get(GlobalState.CHECKCONNECTION).then((http.Response response){
      if(json.decode(response.body)['connected']){
        isConnected = true;
        _globalState.set('isConnected', isConnected);
      } else{
        isConnected = false;
        _globalState.set('isConnected', isConnected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'شبيك لبيك',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/cart': (BuildContext context) => Cart(),
        '/main': (BuildContext context) => MyApp(),
        '/login': (BuildContext context) => LoginPage(),
        '/signup': (BuildContext context) => SignUpPage(),
        '/meals': (BuildContext context) => Meals(),
        '/suclogin': (BuildContext context) => SucLoginPage(),
        '/one': (BuildContext context) => Restaurants(),
        '/cats': (BuildContext context) => Categories(),
        '/checkout': (BuildContext context) => Checkout(),
        '/nextcheckout': (BuildContext context) => NextCheckout(),
        '/myorders': (BuildContext context) => MyOrders(),
        '/single': (BuildContext context) => MySingleOrder(),
        '/about':(BuildContext context) => About(),
        '/home': (BuildContext context) => isLoggedIn && isConnected ? Restaurants() : WelcomePage(),
      },
    );
  }
}

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
}
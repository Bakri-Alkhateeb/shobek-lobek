import 'package:flutter/material.dart';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WelcomePage extends StatefulWidget {

  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  GlobalState _globalState = GlobalState.instance;
  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();

  _WelcomePageState(){
    checkConnection();
  }

  Future<void> checkConnection() async{
    http.get(GlobalState.CHECKCONNECTION).then((http.Response response){
      if(json.decode(response.body)['connected']){
        _globalState.set('isConnected', true);
      } else{
        _globalState.set('isConnected', false);
      }
    });
  }

  Future<void> loginBtn() async{
    if(_globalState.get('isConnected') == true){
      Navigator.of(context).pushNamed('/login');
    }else{
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
                    'تحقق من اتصالك بالانترنت',
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
      checkConnection();
    }
  }

  Future<void> signUpBtn() async{
    if(_globalState.get('isConnected') == true){
      Navigator.of(context).pushNamed('/signup');
    }else{
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
                    'تحقق من اتصالك بالانترنت',
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
      checkConnection();
    }
  }

  Widget _logInButton() {
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: loginBtn,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Color(0xffFFFF00).withAlpha(100),
                offset: Offset(2, 4),
                blurRadius: 8,
                spreadRadius: 2)
          ],
          color: Color(0xffFFFF00),
        ),
        child: Text(
          'سجل دخولك',
          style: TextStyle(fontSize: width * 4.8780487804878048780487804878049 / 100, color: Color(0xff020244), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: signUpBtn,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Color(0xffFFFF00), width: 2),
        ),
        child: Text(
          'أنشئ حساباً',
          style: TextStyle(fontSize: width * 4.8780487804878048780487804878049 / 100, color: Color(0xffffffff), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _title() {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 2.5,
                child: Image(
                  image: AssetImage("assets/main-logo.png"),
                ),
              ),
            ],
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body:SingleChildScrollView(
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(0xff020244),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(
                height: 80,
              ),
              _logInButton(),
              SizedBox(
                height: 20,
              ),
              _signUpButton(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

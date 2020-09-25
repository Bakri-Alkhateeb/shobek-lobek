import 'package:flutter/material.dart';
import 'package:shobek_lobek/functions/globalState.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  GlobalState _globalState = GlobalState.instance;
  final passwordFocus = FocusNode();
  final usernameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

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
                  top: 55,
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
                                "سجل دخولك",
                                style: TextStyle(
                                    color: Color(0xff020244),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              )
                          )
                        ],
                      )
                  )
              ),
            ],
          )
      ),
    );
  }

  Future<void> loginBtn() async{
    if(!_formKey.currentState.validate() ){
      scaffoldState.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xffFFFF00),
            content: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'رجاءً أدخل معلوماتك',
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
    }
    else{
      http.post(GlobalState.LOGIN, body: {
        'username': username.text,
        'password': password.text
      }).then((http.Response response) async{
        if(json.decode(response.body)['statusCode'] == 201){
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', json.decode(response.body)['token']);
          prefs.setString('username', json.decode(response.body)['username']);
          prefs.setString('password', json.decode(response.body)['password']);
          prefs.setInt('userId', json.decode(response.body)['id']);
          prefs.setBool('isLoggedIn', true);
          _globalState.set('userId', json.decode(response.body)['id']);
          username.text = '';
          password.text = '';
          Navigator.of(context).pushNamedAndRemoveUntil('/one',(Route <dynamic> route) => false);
        }
        else if(json.decode(response.body)['statusCode'] == 202){
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
                        'اسم المستخدم خاطئ أو كلمة الرور خاطئة',
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
      });
    }
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                if(isPassword)
                  return 'الرجاء إدخال كلمة المرور';
                else
                  return 'الرجاء إدخال اسم المستخدم';
              }
              return null;
            },
            obscureText: isPassword,
            textInputAction: isPassword ? TextInputAction.go : TextInputAction.next,
            onFieldSubmitted: (v){
              if(!isPassword)
                FocusScope.of(context).requestFocus(passwordFocus);
              else
                loginBtn();
            },
            focusNode: isPassword ? passwordFocus : usernameFocus,
            controller: isPassword ? password : username,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          )
        ],
      ),
    );
  }

  Widget _submitButton() {
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(0xff020244)
        ),
        child: Text(
          'تسجيل الدخول',
          style: TextStyle(
              fontSize: width * 4.8780487804878048780487804878049 / 100,
              color: Colors.white
          ),
        ),
      ),
      onTap: loginBtn,
    );
  }

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/signup');
            },
            child: Text(
              'أنشئ حساباً',
              style: TextStyle(
                  color: Color(0xff020244),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'لا تملك حساباً؟',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _entryField("اسم المستخدم"),
          _entryField("كلمة المرور", isPassword: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldState,
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(height: MediaQuery.of(context).size.height / 4),
                                    Text(
                                      'أدخل معلوماتك لتسجل الدخول',
                                      style: TextStyle(
                                          color: Color(0xff020244),
                                          fontSize: 22
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height / 10),
                                    _emailPasswordWidget(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    _submitButton(),
                                    _createAccountLabel(),
                                    SizedBox(
                                      height: 150,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                  )
              ),
              _header(context)
            ],
          )
      ),
    );
  }
}

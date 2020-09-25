import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shobek_lobek/functions/globalState.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  static TextEditingController username = new TextEditingController();
  static TextEditingController password = new TextEditingController();
  static TextEditingController phoneNumber = new TextEditingController();
  static TextEditingController firstName = new TextEditingController();
  static TextEditingController lastName = new TextEditingController();
  bool isPhoneWrong = true;
  final passwordFocus = FocusNode();
  final usernameFocus = FocusNode();
  final phoneNumberFocus = FocusNode();
  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
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
                                "تسجيل حساب جديد",
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

  void signUpBtn() async{
    if(!_formKey.currentState.validate()){
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
      if(!RegExp('09[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]').hasMatch(phoneNumber.text)){
        setState(() {
          isPhoneWrong = true;
        });
      }
      else{
        setState(() {
          isPhoneWrong = false;
        });
      }
      if(isPhoneWrong){
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
                      'رقم الهاتف غير صحيح',
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
      else{
        http.post(GlobalState.SIGNUP, body: {
          'username': username.text,
          'phoneNumber': phoneNumber.text,
          'password': password.text,
          'firstName': firstName.text,
          'lastName': lastName.text,
        })
            .then((http.Response response){
          if(response.statusCode == 201){
            Navigator.of(context).pushNamedAndRemoveUntil('/suclogin',(Route <dynamic> route) => false);
            username.text = '';
            phoneNumber.text = '';
            password.text = '';
          }
          else if(response.statusCode == 202){
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
                          'اسم المستخدم أو رقم الهاتف موجود مسبقاً',
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
  }

  Widget _entryField(String title, {bool isPassword = false, bool isPhone = false, bool isFirstName = false, bool isLastName = false}) {
    TextEditingController controller;
    if(isPhone){
      controller = phoneNumber;
    }else if(isPassword){
      controller = password;
    }else if(isFirstName){
      controller = firstName;
    }else if(isLastName){
      controller = lastName;
    }else{
      controller = username;
    }
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 10),
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
                if(isPhone)
                  return 'الرجاء إدخال رقم الهاتف';
                else if(isPassword)
                  return 'الرجاء إدخال كلمة المرور';
                else if(isLastName)
                  return 'الرجاء إدخال الكنية';
                else if(isFirstName)
                  return 'الرجاء إدخال الاسم';
                else
                  return 'الرجاء إدخال اسم المستخدم';
              }
              return null;
            },
            textDirection: isFirstName || isLastName ? TextDirection.rtl : TextDirection.ltr,
            keyboardType: isPhone ? TextInputType.number : TextInputType.text,
            inputFormatters: isPhone ? <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ] : null,
            obscureText: isPassword,
            textInputAction: isPassword ? TextInputAction.go : isPhone ? TextInputAction.next : TextInputAction.next,
            onFieldSubmitted: (v){
              if(isPhone)
                FocusScope.of(context).requestFocus(passwordFocus);
              else if(isPassword)
                signUpBtn();
              else if(isFirstName)
                FocusScope.of(context).requestFocus(lastNameFocus);
              else if(isLastName)
                FocusScope.of(context).requestFocus(usernameFocus);
              else
                FocusScope.of(context).requestFocus(phoneNumberFocus);
            },
            focusNode: isPassword ? passwordFocus : isPhone ? phoneNumberFocus : isFirstName ? firstNameFocus : isLastName ? lastNameFocus : usernameFocus,
            controller: controller,
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
      onTap: signUpBtn,
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
          'أنشئ حساباً الآن',
          style: TextStyle(fontSize: width * 4.8780487804878048780487804878049 / 100, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: Text(
              'سجل الدخول',
              style: TextStyle(
                  color: Color(0xff020244),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'هل تملك حساباً بالفعل؟',
            style: TextStyle(fontSize: 14 , fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _entryField("الاسم", isFirstName: true),
          _entryField("الكنية", isLastName: true),
          _entryField("اسم المستخدم"),
          _entryField("رقم الهاتف", isPhone: true),
          _entryField("كلمة المرور", isPassword: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  SizedBox(height: 100),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  _emailPasswordWidget(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  _submitButton(),
                                  _loginAccountLabel(),
                                  SizedBox(height: 150,)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                )
            ),
            _header(context),
          ],
        ),
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:shobek_lobek/functions/globalState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Checkout.dart';

class NextCheckout extends StatefulWidget {
  NextCheckout({Key key}) : super(key: key);

  static Map<int ,int> mealsQuantities = <int, int>{};
  static bool areQueuesTheSame = true;

  @override
  _NextCheckoutState createState() => _NextCheckoutState();
}

class _NextCheckoutState extends State<NextCheckout> with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  TextEditingController locationController = new TextEditingController();
  TextEditingController timeController = new TextEditingController();
  TextEditingController extraNotesController = new TextEditingController();
  GlobalState _globalState = GlobalState.instance;
  double width;
  double height;
  String userId;
  List<int> mealsIds = [];
  List<int> queuesIds = [];
  List<int> tmpQueuesIds = [];
  List<String> mealsNames = [];
  List<int> mealsPrices = [];
  List<String> mealsImages = [];
  int count;
  List<int> quantities;
  List<int> prices;
  int totalPrice;
  double totalTime;
  double sumTime = 0;
  int radioValue = 0;
  int radioValue2 = 0;
  int radioValue3 = 0;
  bool willCustomerBringMeal = true;
  bool isTimeChosen = false;
  bool isTimeInHours = false;
  bool shouldGoUp = false;
  int _dropDownValue = 1;
  String currentHour = Jiffy().format('K');
  bool isChosenTimeValid = true;
  int queueId;
  int orderId;
  List<int> myValues;
  Map<int, int> tmpTimes = new Map<int, int>();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int tmpQueueId = 0;
  int tmpTime = 0;
  int myMinutes = 0;
  bool hasDeliveryService;
  bool isThereExtraInfo = true;


  _NextCheckoutState(){
    userIdSetter();
  }

  @override
  void initState() {
    super.initState();
    orderId = _globalState.get('orderId');
    totalPrice = _globalState.get('totalPrice');
    mealsIds = _globalState.get('mealsIds');
    mealsNames = _globalState.get('mealsNames');
    mealsPrices = _globalState.get('mealsPrices');
    mealsImages = _globalState.get('mealsImages');
    queuesIds = _globalState.get('queuesIds');
    myValues = _globalState.get('quanValues');
    count = mealsIds.length;
    hasDeliveryService = _globalState.get('hasDeliveryService');
    calcTime();
    separateQueues();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> separateQueues() async{
    await Future.forEach(queuesIds,(id){
      if(!tmpQueuesIds.contains(id)){
        tmpQueuesIds.add(id);
      }
    });
    await Future.forEach(tmpQueuesIds, (id){
      bool firstTime = true;
      for(int i = 0; i < mealsIds.length; i++) {
        http.post(GlobalState.SEPARATEQUEUES, body: {
          'resId': _globalState.get('resId').toString(),
          'mealId': mealsIds[i].toString()
        }).then((http.Response response) {
          if (response.statusCode == 201) {
            tmpQueueId = json.decode(response.body)['queueId'];
            tmpTime = json.decode(response.body)['timeInMin'];
            if (tmpQueueId == id) {
              if (firstTime) {
                tmpTimes[id] = myValues[i] * tmpTime;
                firstTime = false;
              } else {
                tmpTimes[id] += myValues[i] * tmpTime;
              }
            }
          }
        });
      }
    });

  }

  Future<void> userIdSetter() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = (prefs.getInt('userId')).toString();
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

  DropdownButton _timeDropdown() => DropdownButton<int>(
    items: [
      DropdownMenuItem<int>(
        value: 1,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 1',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 2,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 2',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 3,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 3',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 4,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 4',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 5,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 5',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 6,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 6',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 7,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 7',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 8,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 8',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 9,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 9',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 10,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 10',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 11,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 11',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 12,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'الساعة 12',
              style: TextStyle(
                  fontSize: 17
              ),
            )
          ],
        ),
      ),
    ],
    onChanged: (value) {
      setState(() {
        _dropDownValue = value;
      });
    },
    value: _dropDownValue,
  );

  Future<void> calcTime() async{
    sumTime = 0;
    setState(() {
      totalTime = double.parse(_globalState.get('totalTime').toString());
    });
    if(NextCheckout.areQueuesTheSame && false){
      http.post(GlobalState.TIMEROUTE, body: {
        'queueId': queuesIds[0].toString(),
        'resId': _globalState.get('resId').toString()
      }).then((http.Response response){
        if(response.statusCode == 201){
          sumTime = json.decode(response.body)['time'] + sumTime;
        }
      });
      setState(() {
        queueId = queuesIds[0];
      });
    } else{
      await Future.forEach(queuesIds, (tmpQueueId) async{
        int mealsTimes = 0;
        int tmpMealsTimes = 0;
        int tmpQueueMealsTimes = 0;
        http.post(GlobalState.MULTIQUEUETIME, body: {
          'queueId': tmpQueueId.toString(),
          'resId': _globalState.get('resId').toString()
        }).then((http.Response response){
          setState(() {
            tmpQueueMealsTimes = json.decode(response.body)['time']; // Here we have the total time in queue
          });
        }).then((void x){
          for(int i = 0; i < mealsIds.length ; i++){
            http.post(GlobalState.RETURNMEALTIME, body: {
              'mealId': mealsIds[i].toString()
            }).then((http.Response response){
              if(response.statusCode == 201){
                if(json.decode(response.body)['QueueId'] == tmpQueueId){
                  tmpMealsTimes = json.decode(response.body)['TimeInMin'] * myValues[i]; // Here we are saving total meals times for that queue
                }
              }
            }).then((void x){
              mealsTimes = tmpQueueMealsTimes + tmpMealsTimes;

              if(mealsTimes >= sumTime){
                setState(() {
                  sumTime = mealsTimes.toDouble();
                });
              }
              print(sumTime);
            });
          }
        });

        await Future.delayed(Duration(milliseconds: 500));
      }).then((void x){
        setState(() {
          _globalState.set('orderTime', totalTime);

          if(!willCustomerBringMeal)
            sumTime = sumTime + 15;

          if(sumTime > 60){
            setState(() {
              myMinutes = sumTime.remainder(60).toInt();
            });

            sumTime = sumTime / 60;
            isTimeInHours = true;
          }
        });
      });
    }
  }

  void _radioButtonHandler(int value) {
    setState(() {
      radioValue = value;
    });
    switch(value){
      case 0:{
        setState(() {
          isTimeChosen = false;
        });
        break;
      }
      case 1:{
        setState(() {
          isTimeChosen = true;
        });
        break;
      }

    }
  }

  void _radioButtonHandler2(int value) {
    setState(() {
      radioValue2 = value;
    });
    switch(value){
      case 0:{
        setState(() {
          willCustomerBringMeal = true;
          calcTime();
        });
        break;
      }
      case 1:{
        setState(() {
          willCustomerBringMeal = false;
          calcTime();
        });
        break;
      }

    }
  }

  void _radioButtonHandler3(int value) {
    setState(() {
      radioValue3 = value;
    });
    switch(value){
      case 0:{
        setState(() {
          isThereExtraInfo = true;
          calcTime();
        });
        break;
      }
      case 1:{
        setState(() {
          isThereExtraInfo = false;
          calcTime();
        });
        break;
      }

    }
  }

  Future<void> _okBtn() async{
    await http.post(GlobalState.ORDERS, body: {
      'mealsIds': mealsIds.toString(),
      'mealsPrices': mealsPrices.toString(),
      'userId': userId,
      'resId': _globalState.get('resId').toString(),
      'orderPrice': totalPrice.toString(),
      'orderTime': totalTime.toString(),
      'orderLocation': locationController.text.isEmpty ? 'سيحضرها الزبون من المطعم' : locationController.text,
      'quantities': myValues.toString(),
      'willUserGetIt': willCustomerBringMeal ? 'true' : 'false',
      'goToDeliveryService': hasDeliveryService || willCustomerBringMeal ? 'false' : 'true',
      'extraInfo': extraNotesController.text.isEmpty ? "لا يوجد إضافات" : extraNotesController.text
    }).then((http.Response response) async{
      for (int i = 0; i < tmpQueuesIds.length; i++){
        await http.post(GlobalState.ADDTOQUEUE, body: {
          'queueId': tmpQueuesIds[i].toString(),
          'timeinmin': tmpTimes[tmpQueuesIds[i]].toString(),
          'resId': _globalState.get('resId').toString(),
          'userId': userId.toString(),
        });
        Future.delayed(Duration(milliseconds: 500));
      }
    });
    http.patch(GlobalState.TMPORDERSDELETE, body: {
      'userId': userId
    }).then((http.Response response){
      mealsIds.clear();
      myValues.clear();
      tmpQueuesIds.clear();
      tmpTimes.clear();
      queuesIds.clear();
      Checkout.mealsQuantities.clear();
      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/one',(Route <dynamic> route) => false);
    });
  }

  Future<void> _timedOrder() async{
    await http.post(GlobalState.ORDERS, body: {
      'mealsIds': mealsIds.toString(),
      'mealsPrices': mealsPrices.toString(),
      'userId': userId,
      'resId': _globalState.get('resId').toString(),
      'orderPrice': totalPrice.toString(),
      'orderTime': totalTime.toString(),
      'orderLocation': locationController.text.isEmpty ? 'سيحضرها الزبون من المطعم' : locationController.text,
      'quantities': myValues.toString(),
      'willUserGetIt': willCustomerBringMeal ? 'true' : 'false',
      'goToDeliveryService': hasDeliveryService || willCustomerBringMeal ? 'false' : 'true',
      'extraInfo': extraNotesController.text.isEmpty ? "لا يوجد إضافات" : extraNotesController.text,
      'timeChosen': _dropDownValue.toString()
    }).then((http.Response response) async{
      for (int i = 0; i < tmpQueuesIds.length; i++){
        await http.post(GlobalState.ADDTOQUEUE, body: {
          'queueId': tmpQueuesIds[i].toString(),
          'timeinmin': tmpTimes[tmpQueuesIds[i]].toString(),
          'resId': _globalState.get('resId').toString(),
          'userId': userId.toString(),
        });
        Future.delayed(Duration(milliseconds: 500));
      }
    });
    http.patch(GlobalState.TMPORDERSDELETE, body: {
      'userId': userId
    }).then((http.Response response){
      mealsIds.clear();
      myValues.clear();
      tmpQueuesIds.clear();
      tmpTimes.clear();
      queuesIds.clear();
      Checkout.mealsQuantities.clear();
      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/one',(Route <dynamic> route) => false);
    });
  }

  Future<void> _cancelBtn() async{
    http.post(GlobalState.TMPORDERSDELETE, body: {
      'userId': userId
    }).then((http.Response response){
      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/one',(Route <dynamic> route) => false);
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Text('هل يناسبك هذا الوقت؟')
            ],
          ),
          content: Column(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  willCustomerBringMeal ?
                  Text(':الوقت المتوقع لتوصيل الطلبية') :
                  Text(':الوقت المتوقع لانتهاء الطلبية'),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.start,
                children: isTimeInHours ? <Widget>[
                  Text('${sumTime.toInt()}'),
                  SizedBox(width: 5,),
                  Text(' ساعة '),
                  Text(" و "),
                  Text('${myMinutes}'),
                  SizedBox(width: 5,),
                  Text(' دقيقة ')
                ] : <Widget>[
                  Text('${sumTime.toInt()}'),
                  SizedBox(width: 5,),
                  Text(' دقيقة ')
                ],
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("إلغاء الطلب"),
              onPressed: _cancelBtn,
            ),
            FlatButton(
              child: new Text("موافق"),
              onPressed: _okBtn,
            ),
          ],
        );
      },
    );
  }

  void _showDialog2() {
    int time1 = shouldGoUp ? sumTime.ceil() : sumTime.floor();
    int time2 = (time1 / 60).toInt() + int.parse(currentHour);
    if (_dropDownValue < time2) {
      setState(() {
        isChosenTimeValid = false;
      });
    } else{
      isChosenTimeValid = true;
    }
    if (!isChosenTimeValid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Text('عذراً, لا يمكنك اختيار هذا الوقت')
              ],
            ),
            content: Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Text('أقل وقت يمكنك اختياره هو: ${time2}')
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("إلغاء الطلب"),
                onPressed: _cancelBtn,
              ),
              FlatButton(
                child: new Text("حسناً"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    } else{
      _timedOrder();
    }
  }

  void sendBtn(){
    if(!willCustomerBringMeal){
      if(_formKey2.currentState.validate()){
        if(isTimeChosen){
          _showDialog2();
        }else{
          _showDialog();
        }
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
                      'يجب عليك اختيار مكان لتوصيل الطلبية',
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
    else if(!isThereExtraInfo){
      if(_formKey.currentState.validate()){
        if(isTimeChosen){
          _showDialog2();
        }else{
          _showDialog();
        }
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
                      'يجب عليك إضافة مواصفات إلى طلبيتك',
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
    }else{
      if(isTimeChosen){
        _showDialog2();
      }else{
        _showDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.grey[200],
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                SizedBox(height: height / 5,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'هل تريد إضافة مواصفات إلى طلبيتك؟',
                        style: TextStyle(
                            fontSize: 17
                        ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: radioValue3,
                            onChanged: _radioButtonHandler3,
                          ),
                          Text(
                            'لا',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: radioValue3,
                            onChanged: _radioButtonHandler3,
                          ),
                          Text(
                            'نعم',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      !isThereExtraInfo ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'ملاحظاتك حول الطلبية',
                              style: TextStyle(
                                  fontSize: 17
                              ),
                            ),
                            SizedBox(height: 15,),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                validator: (val) {
                                  if(val.length == 0) {
                                    return "هذا الحقل لا يمكن أن يكون فارغاً";
                                  }else{
                                    return null;
                                  }
                                },
                                textDirection: TextDirection.rtl,
                                controller: extraNotesController,

                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                SizedBox(width: 10,),
                                Text(
                                  '...مثال: زيادة دبس, زيادة حر',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'هل تود اختيار موعد محدد للطلبية؟',
                        style: TextStyle(
                            fontSize: 17
                        ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: radioValue,
                            onChanged: _radioButtonHandler,
                          ),
                          Text(
                            'لا',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: radioValue,
                            onChanged: _radioButtonHandler,
                          ),
                          Text(
                            'نعم',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      isTimeChosen ? Container(
                        decoration: BoxDecoration(
                          color: Color(0xffEEEEEE),
                        ),
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                Text(
                                  'اختر وقتاً',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                            ),
                            _timeDropdown(),
                            SizedBox(height: 5),
                          ],
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'من تريد أن يوصل طلبيتك؟',
                        style: TextStyle(
                            fontSize: 17
                        ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: radioValue2,
                            onChanged: _radioButtonHandler2,
                          ),
                          Text(
                            'سأحضرها بنفسي',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: radioValue2,
                            onChanged: _radioButtonHandler2,
                          ),
                          Text(
                            'خدمة التوصيل',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      !willCustomerBringMeal ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'إلى أين تريدنا أن نوصل الطلبية؟',
                              style: TextStyle(
                                  fontSize: 17
                              ),
                            ),
                            SizedBox(height: 15,),
                            Form(
                              key: _formKey2,
                              child: TextFormField(
                                validator: (val) {
                                  if(val.length == 0) {
                                    return "هذا الحقل لا يمكن أن يكون فارغاً";
                                  }else{
                                    return null;
                                  }
                                },
                                textDirection: TextDirection.rtl,
                                controller: locationController,
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.location_on),
                                ),
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                SizedBox(width: 10,),
                                Text(
                                  'الرجاء محاولة تحديد موقعك بدقة لسهولة الوصول إليك',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ) : Container(),
                      SizedBox(height: 150,)
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
                      RaisedButton(
                        color: Colors.green,
                        onPressed: sendBtn,
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
                                    'إرسال',
                                    style: TextStyle(
                                        fontSize: width * 4.8780487804878048780487804878049 / 100,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
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
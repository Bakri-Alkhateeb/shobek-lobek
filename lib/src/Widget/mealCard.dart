import 'package:shobek_lobek/functions/globalState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../Meals.dart';

// ignore: must_be_immutable
class MealCard extends StatefulWidget{
  String mealName;
  String mealPrice;
  String mealDesc;
  String mealImage;
  int mealId;
  int index;

  static bool isMealsIdsEmpty = true;

  MealCard(int mealId, String mealName, String mealPrice, String mealDesc, String mealImage, int index){
    this.mealName = mealName;
    this.mealPrice = mealPrice;
    this.mealDesc = mealDesc;
    this.mealImage = mealImage;
    this.mealId = mealId;
    this.index = index;
  }

  @override
  State<StatefulWidget> createState() {
    return _MealCardState(mealId, mealName, mealPrice, mealDesc, mealImage, index);
  }
}

class _MealCardState extends State<MealCard> with SingleTickerProviderStateMixin{

  final GlobalKey<ScaffoldState> scaffoldState =  new GlobalKey<ScaffoldState>();
  AnimationController _animationController;
  Animation<double> _curvedAnimation;
  String mealPrice;
  String mealImage;
  String mealName;
  String mealDesc;
  double width;
  int mealId;
  int refResId;
  final GlobalState _globalState = GlobalState.instance;
  int mealsCount = 0;
  List <int> mealsId = [];
  int index;
  String userId;
  bool checkBoxValue = false;

  _MealCardState(int mealId, String mealName, String mealPrice, String mealDesc, String mealImage, int index){
    this.mealPrice = mealPrice;
    this.mealImage = mealImage;
    this.mealName = mealName;
    this.mealDesc = mealDesc;
    this.index = index;
    this.mealId = mealId;
    fetchMeals();
  }


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flip(bool reverse) {
    if (_animationController.isAnimating) return;
    if (reverse) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void checkBoxValueChanger(bool value){
    setState(() {
      checkBoxValue = value;
    });
    if(checkBoxValue){
      if(!Meals.mealsIds.contains(mealId)){
        setState(() {
          MealCard.isMealsIdsEmpty = false;
        });
        Meals.mealsIds.add(mealId);
      }
    }else{
      if(Meals.mealsIds.contains(mealId)){
        if(Meals.mealsIds.length == 1){
          MealCard.isMealsIdsEmpty = true;
        }
        Meals.mealsIds.remove(mealId);
      }
    }
  }

  Future<void> fetchMeals() async{

    await http.post(GlobalState.MEALS, body: {
      'resId': _globalState.get('resId').toString(),
    }).then((http.Response response){
      setState(() {
        mealsCount = json.decode(response.body)['count'];
        mealsId = [];
      });

      for(int i = 0; i < mealsCount; i++){
        mealsId.add(json.decode(response.body)['mealsId'][i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var _width = MediaQuery.of(context).size.width / 2;
    return FlipView(
        animationController: _curvedAnimation,
        front: Stack(
          children: <Widget>[
            InkWell(
              onTap: () => _flip(true),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        width: _width,
                        height: _width - 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FadeInImage(
                            image: NetworkImage(mealImage),
                            fit: BoxFit.cover,
                            placeholder: AssetImage('assets/loading.gif'),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      mealName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Checkbox(
                  value: checkBoxValue,
                  onChanged: checkBoxValueChanger,
                  checkColor: Color(0xffFFFF00),
                  activeColor: Color(0xff020244),
                )
              ],
            )
          ],
        ),
        back: InkWell(
          onTap: () {
            _flip(false);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: _width,
                    height: _width - 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Color(0xff020244),
                        child: Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 30, right: 5, left: 5, bottom: 5),
                                    width: _width - 10,
                                    child: Text(
                                      mealDesc,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: _width,
                              height: 25,
                              child: Text(
                                'السعر: ${mealPrice} ل.س',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff020244),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              color: Color(0xffFFFF00),
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
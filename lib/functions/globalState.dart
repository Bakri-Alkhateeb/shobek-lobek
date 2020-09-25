class GlobalState{
  static const SERVER = 'http://192.168.1.38:3000/';
  static const CHECKCONNECTION = 'http://192.168.1.38:3000/checkConnection';
  static const SIGNUP = 'http://192.168.1.38:3000/signup';
  static const LOGIN = 'http://192.168.1.38:3000/login';
  static const TMPORDERS = 'http://192.168.1.38:3000/tmpOrders';
  static const FETCHCART = 'http://192.168.1.38:3000/cart';
  static const TMPORDERSDELETE = 'http://192.168.1.38:3000/tmpOrdersDelete';
  static const RESTAURANTS = 'http://192.168.1.38:3000/restaurants';
  static const CATEGORIES = 'http://192.168.1.38:3000/categories';
  static const MEALS = 'http://192.168.1.38:3000/meals';
  static const RESIMAGES = 'http://192.168.1.38:3000/resImages/';
  static const MEALSIMAGES = 'http://192.168.1.38:3000/mealsImages/';
  static const CATSIMAGES = 'http://192.168.1.38:3000/catsImages/';
  static const ORDERSINSERT = 'http://192.168.1.38:3000/ordersInsert';
  static const TIMEROUTE = 'http://192.168.1.38:3000/timeRoute';
  static const ORDERS = 'http://192.168.1.38:3000/orders';
  static const MULTIQUEUETIME = 'http://192.168.1.38:3000/multiQueueTime';
  static const MYORDERS = 'http://192.168.1.38:3000/myOrders';
  static const GETUSERID = 'http://192.168.1.38:3000/getUserId';
  static const MYSINGLEORDER = 'http://192.168.1.38:3000/mySingleOrder';
  static const ADDTOQUEUE = 'http://192.168.1.38:3000/addToQueue';
  static const FETCHRESNAME = 'http://192.168.1.38:3000/fetchResName';
  static const SEPARATEQUEUES = 'http://192.168.1.38:3000/separateQueues';
  static const RETURNMEALTIME = 'http://192.168.1.38:3000/returnMealTime';
  final Map<String, dynamic> _data = <String, dynamic>{};
  static GlobalState instance = new GlobalState._();


  GlobalState._();

  set(String key, dynamic value) => _data[key] = value;
  get(String key) => _data[key];
}
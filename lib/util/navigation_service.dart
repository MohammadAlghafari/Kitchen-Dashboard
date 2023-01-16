import 'package:flutter/cupertino.dart';

//put the context as global variable to reach from anyehere inside the project
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
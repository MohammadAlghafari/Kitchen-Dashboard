import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/view/screens/inventory/inventory_screen.dart';
import 'package:thecloud/view/screens/ordersHistory/orders_history_screen.dart';
import 'package:thecloud/view/screens/ordersStatistics/orders_statistics_screen.dart';
import 'package:thecloud/view/screens/reset_password/reset_password_screen.dart';
import 'common/prefs_keys.dart';
import 'injection_container.dart';
import 'view/screens/home/home_screen.dart';
import 'view/screens/login/login_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final SharedPreferences sharedPreferences =
        serviceLocator<SharedPreferences>();
    final Widget view;
    final bool? auth = sharedPreferences.getBool(PrefsKeys.authenticated);
    // Check if not authenticated redirect to login screen
    if ((auth == null || !auth) && settings.name != ResetPasswordScreen.routeName) {
      return MaterialPageRoute(
          builder: (_) => const LoginScreen(), settings: settings);
    }
    switch (settings.name) {
      case HomeScreen.routeName:
        view = const HomeScreen();
        break;
      case LoginScreen.routeName:
        view = const LoginScreen();
        break;
      case ResetPasswordScreen.routeName:
        view = const ResetPasswordScreen();
        break;
      case InventoryScreen.routeName:
        view = const InventoryScreen();
        break;
      case OrdersHistoryScreen.routeName:
        view = const OrdersHistoryScreen();
        break;
      case OrdersStatisticsScreen.routeName:
        view = const OrdersStatisticsScreen();
        break;
      default:
        // If there is no such named route in the switch statement
        view = const LoginScreen();
    }
    return MaterialPageRoute(builder: (_) => view, settings: settings);
  }
}

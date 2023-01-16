import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/view/screens/reset_password/reset_password_screen.dart';
import 'package:thecloud/viewModels/home_view_model.dart';

import '../common/prefs_keys.dart';
import '../infrastructure/catalog_facade_service.dart';
import '../util/global_functions.dart';
import '../util/navigation_service.dart';
import '../view/screens/home/home_screen.dart';
import '../view/screens/login/login_screen.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(
      {required this.catalogFacadeService,
      required this.secureStorage,
      required this.sharedPreferences});

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _resetPasswordLoading = false;

  bool get resetPasswordLoading => _resetPasswordLoading;

  final CatalogFacadeService catalogFacadeService;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  void login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await catalogFacadeService.login(
        username: username,
        password: password,
      );
      if (!res.loginStatus!) {
        showToast(message: res.message!);
        _isLoading = false;
        notifyListeners();
        return;
      }
      final loginResponse = res.data;
      if (loginResponse!.apiToken == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (kIsWeb) {
        sharedPreferences.setString(
            PrefsKeys.apiToken, loginResponse.apiToken!);
      } else {
        secureStorage.write(
            key: PrefsKeys.apiToken, value: loginResponse.apiToken!);
      }
      if (loginResponse.resetPassword!) {
        Navigator.of(NavigationService.navigatorKey.currentState!.context)
            .pushReplacementNamed(ResetPasswordScreen.routeName);
        return;
      }
      sharedPreferences.setString(PrefsKeys.userName, username);
      sharedPreferences.setString(PrefsKeys.password, password);
      sharedPreferences.setString(
          PrefsKeys.kitchenName, loginResponse.kitchenName!);
      sharedPreferences.setBool(PrefsKeys.authenticated, true);

      Navigator.of(NavigationService.navigatorKey.currentState!.context)
          .pushReplacementNamed(HomeScreen.routeName);
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  void resetPassword({
    required String password,
  }) async {
    _resetPasswordLoading = true;
    notifyListeners();
    try {
      final res = await catalogFacadeService.resetPassword(
        password: password,
      );
      if (!res.loginStatus!) {
        showToast(message: res.message!);
        _resetPasswordLoading = false;
        _isLoading = false;
        notifyListeners();
        Navigator.of(NavigationService.navigatorKey.currentState!.context)
            .pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
        return;
      }
      if (res.data!) {
        _isLoading = false;
        notifyListeners();
        Navigator.of(NavigationService.navigatorKey.currentState!.context)
            .pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
    _resetPasswordLoading = false;
    _isLoading = false;
    notifyListeners();
  }

  void logout() async {
    try {
      await catalogFacadeService.logout();
      Provider.of<HomeViewModel>(
              NavigationService.navigatorKey.currentState!.context,
              listen: false)
          .clearData();
      secureStorage.delete(
        key: PrefsKeys.apiToken,
      );
      sharedPreferences.remove(PrefsKeys.apiToken);
      sharedPreferences.remove(PrefsKeys.orderHistoryStartDate);
      sharedPreferences.remove(PrefsKeys.orderHistoryEndDate);
      sharedPreferences.remove(PrefsKeys.menuStatStartDate);
      sharedPreferences.remove(PrefsKeys.menuStatEndDate);
      sharedPreferences.setBool(PrefsKeys.authenticated, false);
      Navigator.of(NavigationService.navigatorKey.currentState!.context)
          .pushNamedAndRemoveUntil(
              LoginScreen.routeName, (Route<dynamic> route) => false);
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }
}

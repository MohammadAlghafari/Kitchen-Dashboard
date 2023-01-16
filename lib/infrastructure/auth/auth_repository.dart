import 'package:dio/dio.dart';
import 'package:thecloud/infrastructure/auth/api/reset_password_api.dart';

import '../../common/prefs_keys.dart';
import '../apiUtil/response_wrapper.dart';
import 'api/login_api.dart';
import 'api/logout_api.dart';
import 'auth_interface.dart';
import 'model/login_response.dart';

class AuthRepository implements AuthInterface {
  final LoginApi loginApi;
  final LogoutApi logoutApi;
  final ResetPasswordApi resetPasswordApi;

  AuthRepository({
    required this.loginApi,
    required this.logoutApi,
    required this.resetPasswordApi,
  });

  @override
  Future<ResponseWrapper<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    Response response = await loginApi.login(
      username: username,
      password: password,
    );
    var res = ResponseWrapper<LoginResponse>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = LoginResponse.fromMap(response.data[PrefsKeys.data]);
    } else {
      res.data = LoginResponse.fromMap({});
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<LoginResponse>> logout() async {
    Response response = await logoutApi.logout();
    var res = ResponseWrapper<LoginResponse>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = LoginResponse.fromMap(response.data[PrefsKeys.data]);
    } else {
      res.data = LoginResponse.fromMap({});
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<bool>> resetPassword(
      {required String password}) async {
    Response response =
        await resetPasswordApi.resetPassword(password: password);
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      if (response.data[PrefsKeys.data]) {
        res.data = response.data[PrefsKeys.data];
      } else {
        res.data = false;
      }
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }
}

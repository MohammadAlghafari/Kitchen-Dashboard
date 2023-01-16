import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class LoginApi {
  LoginApi({required this.dio});

  final Dio dio;

  Future<dynamic> login(
      {required String username, required String password,}) async {
    final params = {
      'user_name': username,
      'password': password,
    };
    Response response = await dio.post(
      Urls.login,
      data: params,
    );
    return response;
  }
}

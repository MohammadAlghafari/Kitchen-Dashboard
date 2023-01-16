import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class LogoutApi {
  LogoutApi({required this.dio});

  final Dio dio;

  Future<dynamic> logout() async {
    Response response = await dio.post(
      Urls.login,
    );
    return response;
  }
}

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class ResetPasswordApi {
  ResetPasswordApi({required this.dio});

  final Dio dio;

  Future<dynamic> resetPassword({
    required String password,
  }) async {
    final params = {
      'password': password,
    };
    Response response = await dio.post(
      Urls.resetPassword,
      data: params,
    );
    return response;
  }
}

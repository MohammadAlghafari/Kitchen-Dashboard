import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class ConfirmSpecialMessageApi {
  ConfirmSpecialMessageApi({required this.dio});

  final Dio dio;

  Future<dynamic> confirmSpecialMessage() async {
    final params = {
      'local_time': DateTime.now().toString(),
    };

    Response response = await dio.post(
      Urls.confirmSpecialMessage,
      data: params,
    );
    return response;
  }
}

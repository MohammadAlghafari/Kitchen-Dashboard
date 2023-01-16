import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class TemporaryCloseKitchenApi {
  TemporaryCloseKitchenApi({required this.dio});

  final Dio dio;

  Future<dynamic> temporaryCloseKitchen(
      {required int duration, }) async {
    final params = {
      'duration': duration,
      'request_time_local': DateTime.now().toString(),
    };
  
    Response response = await dio.post(
      Urls.closeKitchen,
      data: params,
    );
    return response;
  }
}

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class UpdateCancelOrderRequestApi {
  UpdateCancelOrderRequestApi({required this.dio});

  final Dio dio;

  Future<dynamic> updateCancelOrderRequest(
      {required int orderId, required String foodPrepared}) async {
    final params = {
      'cancel_request': true,
      'cancelled_order_id': orderId,
      'cancelled_accept_time': DateTime.now().toString(),
      'food_prepared': foodPrepared,
    };
  
    Response response = await dio.post(
      Urls.updateCancelOrderRequest,
      data: params,
    );
    return response;
  }
}

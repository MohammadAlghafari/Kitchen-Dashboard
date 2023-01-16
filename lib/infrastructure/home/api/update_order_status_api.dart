import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class UpdateOrderStatusApi {
  UpdateOrderStatusApi({required this.dio});

  final Dio dio;

  Future<dynamic> updateOrderStatus(
      {required int orderId, required String orderStatus, int? codAmount}) async {
    final params = {
      'order_id': orderId,
      'status': orderStatus,
    };
    if (codAmount != null) {
      params['amount'] = codAmount;
    }
    Response response = await dio.post(
      Urls.updateOrderStatus,
      data: params,
    );
    return response;
  }
}

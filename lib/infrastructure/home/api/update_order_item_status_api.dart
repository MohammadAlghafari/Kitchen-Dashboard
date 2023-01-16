import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class UpdateOrderItemStatusApi {
  UpdateOrderItemStatusApi({required this.dio});

  final Dio dio;

  Future<dynamic> updateOrderItemStatus({
    required int itemId,
    required int itemMenuId,
    required int orderId,
    required int orderItemStatus,
  }) async {
    final params = {
      'item_id': itemId,
      'item_menu_id': itemMenuId,
      'order_id': orderId,
      'items_status': orderItemStatus,
    };
    Response response = await dio.post(
      Urls.updateOrderItemStatus,
      data: params,
    );
    return response;
  }
}

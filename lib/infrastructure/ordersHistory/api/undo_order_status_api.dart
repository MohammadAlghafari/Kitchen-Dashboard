import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class UndoOrderStatusApi {
  UndoOrderStatusApi({required this.dio});

  final Dio dio;

  Future<dynamic> undoOrderStatus({required int orderId}) async {
    final params = {
      'order_id': orderId,
    };
    Response response = await dio.post(
      Urls.undoOrderStatus,
      data: params,
    );
    return response;
  }
}

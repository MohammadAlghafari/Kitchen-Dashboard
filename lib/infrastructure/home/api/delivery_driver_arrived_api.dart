import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class DeliveryGuyArrivedApi {
  DeliveryGuyArrivedApi({required this.dio});

  final Dio dio;

  Future<dynamic> deliveryGuyArrived(
      {required int orderId,}) async {
    final params = {
      'order_id': orderId,
    };
  
    Response response = await dio.post(
      Urls.deliveryGuyArrived,
      data: params,
    );
    return response;
  }
}

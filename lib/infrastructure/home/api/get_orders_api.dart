import 'dart:developer';

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetOrdersApi {
  GetOrdersApi({required this.dio});


  final Dio dio;

  Future<dynamic> getAllOrders() async {
   
    Response response =
        await dio.get(Urls.getAllOrders,);
    log("ORDERS API IS BEING CALLED");
    return response;
  }
}

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class PeriodicCheckOrdersApi {
  PeriodicCheckOrdersApi({required this.dio});


  final Dio dio;

  Future<dynamic> periodicCheckOrders() async {
    
    Response response =
        await dio.get(Urls.periodicCheckOrders,);
    return response;
  }
}

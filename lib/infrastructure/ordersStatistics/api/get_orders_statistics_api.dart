import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetOrdersStatisticsApi {
  GetOrdersStatisticsApi({required this.dio});

  final Dio dio;

  Future<dynamic> getOrdersStatistics(
      {required String startDate,
      required String endDate,
      required int pageLimit,
      required int pageNumber,
      bool export = false,
      String menuName = ''}) async {
    final params = {
      'start_date': startDate,
      'end_date': endDate,
      'page_limit': pageLimit,
      'page_number': pageNumber,
    };
    if (menuName.isNotEmpty) {
      params['menu_name'] = menuName;
    }
    if (export) {
      params['request'] = 'export';
    }
    Response response = await dio.post(Urls.getOrdersStatistics, data: params);
    return response;
  }
}

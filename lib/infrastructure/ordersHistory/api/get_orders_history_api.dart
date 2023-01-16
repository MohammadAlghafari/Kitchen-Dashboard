import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetOrdersHistoryApi {
  GetOrdersHistoryApi({required this.dio});

  final Dio dio;

  Future<dynamic> getOrdersHistory({
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int pageLimit,
    required int pageNumber,
    String orderId = '',
    String platform = '',
    String status = '',
    Map<String, String>? sort,
    bool export = false,
  }) async {
    final params = {
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'page_limit': pageLimit,
      'page_number': pageNumber,
      'sort': sort,
    };
    if (orderId.isNotEmpty) {
      params['search_order_id'] = orderId;
    }
    if (platform.isNotEmpty) {
      params['search_platform'] = platform;
    }
    if (status.isNotEmpty) {
      params['search_status'] = status;
    }
    if (export) {
      params['request'] = 'export';
    }
    Response response = await dio.post(
      Urls.getOrdersHistory,
      data: params,
    );
    return response;
  }
}

import 'package:dio/dio.dart';
import 'package:thecloud/infrastructure/apiUtil/response_wrapper.dart';
import 'package:thecloud/infrastructure/ordersStatistics/api/get_orders_statistics_api.dart';
import 'package:thecloud/infrastructure/ordersStatistics/model/order_statistics.dart';

import '../../common/prefs_keys.dart';
import 'orders_statistics_interface.dart';

class OrdersStatisticsRepository implements OrdersStatisticsInterface {
  OrdersStatisticsRepository({required this.getOrdersStatisticsApi});
  final GetOrdersStatisticsApi getOrdersStatisticsApi;

  @override
  Future<ResponseWrapper<List<OrderStatistics>>> getOrdersStatistics(
      {required String startDate,
      required String endDate,
      required int pageLimit,
      required int pageNumber,
      bool export = false,
      String menuName = ''}) async {
    Response response = await getOrdersStatisticsApi.getOrdersStatistics(
      startDate: startDate,
      endDate: endDate,
      pageLimit: pageLimit,
      pageNumber: pageNumber,
      menuName: menuName,
      export: export,
    );
    var res = ResponseWrapper<List<OrderStatistics>>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = (response.data[PrefsKeys.data] as List)
          .map<OrderStatistics>((json) => OrderStatistics.fromMap(json))
          .toList();
    } else {
      res.data = [];
    }

    res.totalRowCount = response.data[PrefsKeys.totalRowCount].toString();
    res.message = response.data[PrefsKeys.message];
    return res;
  }
}

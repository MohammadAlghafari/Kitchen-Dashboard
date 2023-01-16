
import 'package:thecloud/infrastructure/ordersStatistics/model/order_statistics.dart';

import '../apiUtil/response_wrapper.dart';

abstract class OrdersStatisticsInterface {
  Future<ResponseWrapper<List<OrderStatistics>>> getOrdersStatistics(
     {required String startDate,
      required String endDate,
      required int pageLimit,
      required int pageNumber,
      bool export = false,
      String menuName = ''}
  );
}

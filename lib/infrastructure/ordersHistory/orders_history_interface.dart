import 'package:thecloud/infrastructure/ordersHistory/model/order_history_details.dart';

import '../apiUtil/response_wrapper.dart';
import 'model/undo_order_response.dart';

abstract class OrdersHistoryInterface {
  Future<ResponseWrapper<List<OrderHistoryDetails>>> getOrdersHistory({
    required String startDate,
    required String endDate,
    required int pageLimit,
    required int pageNumber,
    String orderId = '',
    String platform = '',
    String status = '',
    bool export = false,
  });
  Future<ResponseWrapper<UndoOrderResponse>> undoOrderStatus({required int orderId});
}

import 'package:dio/dio.dart';
import 'package:thecloud/infrastructure/ordersHistory/api/get_orders_history_api.dart';
import 'package:thecloud/infrastructure/apiUtil/response_wrapper.dart';
import 'package:thecloud/infrastructure/ordersHistory/api/undo_order_status_api.dart';
import 'package:thecloud/infrastructure/ordersHistory/orders_history_interface.dart';

import '../../common/prefs_keys.dart';
import 'model/order_history_details.dart';
import 'model/undo_order_response.dart';

class OrdersHistoryRepository implements OrdersHistoryInterface {
  OrdersHistoryRepository({
    required this.getOrdersHistoryApi,
    required this.undoOrderStatusApi,
  });
  final GetOrdersHistoryApi getOrdersHistoryApi;
  final UndoOrderStatusApi undoOrderStatusApi;

  @override
  Future<ResponseWrapper<List<OrderHistoryDetails>>> getOrdersHistory({
    required String startDate,
    required String endDate,
     String? startTime,
     String? endTime,
    required int pageLimit,
    required int pageNumber,
    String orderId = '',
    String platform = '',
    String status = '',
    Map<String, String>? sort,
    bool export = false,
  }) async {
    Response response = await getOrdersHistoryApi.getOrdersHistory(
      startDate: startDate,
      endDate: endDate,
      startTime: startTime!,
      endTime: endTime!,
      pageLimit: pageLimit,
      pageNumber: pageNumber,
      orderId: orderId,
      platform: platform,
      status: status,
      sort: sort,
      export: export,
    );
    var res = ResponseWrapper<List<OrderHistoryDetails>>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = (response.data[PrefsKeys.data] as List)
          .map<OrderHistoryDetails>((json) => OrderHistoryDetails.fromMap(json))
          .toList();
    } else {
      res.data = [];
    }

    res.totalRowCount = response.data[PrefsKeys.totalRowCount].toString();
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<UndoOrderResponse>> undoOrderStatus(
      {required int orderId}) async {
    Response response =
        await undoOrderStatusApi.undoOrderStatus(orderId: orderId);
    var res = ResponseWrapper<UndoOrderResponse>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = UndoOrderResponse.fromMap(response.data[PrefsKeys.data]);
    } else {
      res.data = UndoOrderResponse.fromMap({});
    }

    res.message = response.data[PrefsKeys.message];
    return res;
  }
}

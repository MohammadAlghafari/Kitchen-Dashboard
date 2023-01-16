import 'package:dio/dio.dart';
import 'package:thecloud/infrastructure/home/api/confirm_special_message_api.dart';
import 'package:thecloud/infrastructure/home/api/delivery_driver_arrived_api.dart';
import 'package:thecloud/infrastructure/home/api/get_app_version.dart';
import 'package:thecloud/infrastructure/home/api/get_qr_code_file_name.dart';
import 'package:thecloud/infrastructure/home/api/temporary_close_kitchen_api.dart';
import 'package:thecloud/infrastructure/home/api/update_order_display_time_api.dart';
import 'package:thecloud/infrastructure/home/model/app_version_model.dart';
import 'api/update_cancel_order_request_api.dart';
import 'api/update_order_item_status_api.dart';

import '../../common/prefs_keys.dart';
import '../apiUtil/response_wrapper.dart';
import 'api/get_orders_api.dart';
import 'api/get_print_receipt_api.dart';
import 'api/periodic_check_orders_api.dart';
import 'api/update_order_status_api.dart';
import 'home_interface.dart';
import 'model/order.dart';
import 'model/order_update_item.dart';
import 'model/print_receipt.dart';

class HomeRepository implements HomeInterface {
  final GetOrdersApi getOrdersApi;
  final UpdateOrderStatusApi updateOrderStatusApi;
  final UpdateOrderDisplayTimeApi updateOrderDisplayTimeApi;
  final PeriodicCheckOrdersApi periodicCheckOrdersApi;
  final GetPrintReceiptApi printReceiptApi;
  final UpdateOrderItemStatusApi updateOrderItemStatusApi;
  final UpdateCancelOrderRequestApi updateCancelOrderRequestApi;
  final GetAppVersionApi getAppVersionApi;
  final DeliveryGuyArrivedApi deliveryGuyArrivedApi;
  final TemporaryCloseKitchenApi temporaryCloseKitchenApi;
  final ConfirmSpecialMessageApi confirmSpecialMessageApi;
  final GetQrCodeFileNameApi getQrCodeFileNameApi;
  HomeRepository({
    required this.getOrdersApi,
    required this.updateOrderStatusApi,
    required this.periodicCheckOrdersApi,
    required this.printReceiptApi,
    required this.updateOrderItemStatusApi,
    required this.updateCancelOrderRequestApi,
    required this.getAppVersionApi,
    required this.deliveryGuyArrivedApi,
    required this.temporaryCloseKitchenApi,
    required this.confirmSpecialMessageApi,
    required this.getQrCodeFileNameApi,
    required this.updateOrderDisplayTimeApi,
  });

  @override
  Future<ResponseWrapper<List<Order>>> getOrders() async {
    Response response = await getOrdersApi.getAllOrders();
    var res = ResponseWrapper<List<Order>>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = (response.data[PrefsKeys.data] as List)
          .map<Order>((json) => Order.fromMap(json))
          .toList();
    } else {
      res.data = [];
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<OrderUpdateItem>> updateOrderStatus(
      {required int orderId,
      required String orderStatus,
      int? codAmount}) async {
    Response response = await updateOrderStatusApi.updateOrderStatus(
        orderId: orderId, orderStatus: orderStatus, codAmount: codAmount);
    var res = ResponseWrapper<OrderUpdateItem>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = OrderUpdateItem.fromMap(response.data[PrefsKeys.data]);
    } else {
      res.data = OrderUpdateItem.fromMap({});
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<List<Order>>> periodicCheckOrders() async {
    Response response = await periodicCheckOrdersApi.periodicCheckOrders();
    var res = ResponseWrapper<List<Order>>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = (response.data[PrefsKeys.data] as List)
          .map<Order>((json) => Order.fromMap(json))
          .toList();
    } else {
      res.data = [];
    }
    res.message = response.data[PrefsKeys.message];
    res.specialMessage = response.data[PrefsKeys.specialMessage];
    res.specialMessageData = response.data[PrefsKeys.specialMessageData];
    return res;
  }

  @override
  Future<ResponseWrapper<PrintReceipt>> getPrintReceiptApi(
      {required int orderId, required String receiptType}) async {

    Response response = await printReceiptApi.getPrintReceipt(
      orderId: orderId,
      receiptType: receiptType,
    );
    var res = ResponseWrapper<PrintReceipt>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = PrintReceipt.fromMap(response.data[PrefsKeys.data]);
    } else {
      res.data = PrintReceipt.fromMap({});
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<bool>> updateOrderItemStatus(
      {required int itemId,
      required int itemMenuId,
      required int orderId,
      required int orderItemStatus}) async {
    Response response = await updateOrderItemStatusApi.updateOrderItemStatus(
      itemId: itemId,
      itemMenuId: itemMenuId,
      orderId: orderId,
      orderItemStatus: orderItemStatus,
    );
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = response.data[PrefsKeys.data];
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<bool>> updateCancelOrderRequest(
      {required int orderId, required String foodPrepared}) async {
    Response response = await updateCancelOrderRequestApi
        .updateCancelOrderRequest(orderId: orderId, foodPrepared: foodPrepared);
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      // if (response.data is bool) {
      if (response.data[PrefsKeys.data] is bool) {
        res.data = response.data[PrefsKeys.data];
      } else {
        res.data = false;
      }
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<bool>> temporaryCloseKitchen({
    required int duration,
  }) async {
    Response response = await temporaryCloseKitchenApi.temporaryCloseKitchen(
      duration: duration,
    );
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = response.data[PrefsKeys.data];
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<AppVersionModel> getAppVersion() async {
    Response response = await getAppVersionApi.getAppVersion();
    var res = AppVersionModel(
      appVersion: response.data['version'],
      appDownloadUrl: response.data['url'],
    );
    return res;
  }

  @override
  void updateOrderDisplayTime({required String updateUrl}){
    updateOrderDisplayTimeApi.updateOrderDisplayTime(updateUrl: updateUrl);
  }

  @override
  Future<ResponseWrapper<bool>> deliveryGuyArrived(
      {required int orderId}) async {
    Response response = await deliveryGuyArrivedApi.deliveryGuyArrived(
      orderId: orderId,
    );
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = response.data[PrefsKeys.data];
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<bool>> confirmSpecialMessage() async {
    Response response = await confirmSpecialMessageApi.confirmSpecialMessage();
    var res = ResponseWrapper<bool>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = response.data[PrefsKeys.data];
    } else {
      res.data = false;
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<String>> getQrCodeFileName() async {
    Response response = await getQrCodeFileNameApi.getQrCodeFileName();
    var res = ResponseWrapper<String>();
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    if (res.loginStatus!) {
      res.data = response.data[PrefsKeys.data];
    } else {
      res.data = '';
    }
    res.message = response.data[PrefsKeys.message];
    return res;
  }
}

import 'package:thecloud/infrastructure/home/model/app_version_model.dart';

import '../apiUtil/response_wrapper.dart';
import 'model/order.dart';
import 'model/order_update_item.dart';
import 'model/print_receipt.dart';

abstract class HomeInterface {
  Future<ResponseWrapper<List<Order>>> getOrders();

  Future<ResponseWrapper<List<Order>>> periodicCheckOrders();

  Future<ResponseWrapper<OrderUpdateItem>> updateOrderStatus(
      {required int orderId, required String orderStatus, int codAmount});

  Future<ResponseWrapper<bool>> updateOrderItemStatus({
    required int itemId,
    required int itemMenuId,
    required int orderId,
    required int orderItemStatus,
  });

  Future<ResponseWrapper<bool>> updateCancelOrderRequest(
      {required int orderId, required String foodPrepared});

  Future<ResponseWrapper<bool>> temporaryCloseKitchen({required int duration});

  Future<ResponseWrapper<bool>> deliveryGuyArrived({
    required int orderId,
  });

  Future<AppVersionModel> getAppVersion();
  Future<ResponseWrapper<String>> getQrCodeFileName();
  Future<ResponseWrapper<bool>> confirmSpecialMessage();
  void updateOrderDisplayTime({required String updateUrl});

  Future<ResponseWrapper<PrintReceipt>> getPrintReceiptApi({
    required int orderId,
    required String receiptType,
  });
}

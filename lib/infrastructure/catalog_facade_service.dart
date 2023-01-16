import 'package:thecloud/infrastructure/home/model/app_version_model.dart';
import 'package:thecloud/infrastructure/inventory/inventory_repository.dart';
import 'package:thecloud/infrastructure/inventory/model/addon_items.dart';
import 'package:thecloud/infrastructure/ordersHistory/model/order_history_details.dart';
import 'package:thecloud/infrastructure/ordersHistory/orders_history_repository.dart';
import 'package:thecloud/infrastructure/ordersStatistics/model/order_statistics.dart';

import 'apiUtil/response_wrapper.dart';
import 'home/home_repository.dart';
import 'home/model/order.dart';
import 'home/model/order_update_item.dart';
import 'home/model/print_receipt.dart';
import 'inventory/model/change_availability_response.dart';
import 'inventory/model/kitchen_menu.dart';
import 'auth/auth_repository.dart';
import 'auth/model/login_response.dart';
import 'ordersHistory/model/undo_order_response.dart';
import 'ordersStatistics/orders_statistics_repository.dart';

// This class is the medium between repositories
// and business logic which is provider in this case
// business model request data from the catalog
// and catalog redirect that request and retrieve
// that data and emitted back to business model

class CatalogFacadeService {
  const CatalogFacadeService(
      {required this.homeRepository,
      required this.authRepository,
      required this.ordersHistoryRepository,
      required this.ordersStatisticsRepository,
      required this.inventoryRepository});

  final HomeRepository homeRepository;
  final AuthRepository authRepository;
  final InventoryRepository inventoryRepository;
  final OrdersHistoryRepository ordersHistoryRepository;
  final OrdersStatisticsRepository ordersStatisticsRepository;

  Future<ResponseWrapper<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    return await authRepository.login(
      username: username,
      password: password,
    );
  }

  Future<ResponseWrapper<bool>> resetPassword(
      {required String password}) async {
    return await authRepository.resetPassword(
      password: password,
    );
  }

  Future<ResponseWrapper<LoginResponse>> logout() async {
    return await authRepository.logout();
  }

  Future<ResponseWrapper<List<Order>>> periodicCheckOrders() async {
    return await homeRepository.periodicCheckOrders();
  }

  Future<ResponseWrapper<List<Order>>> getOrders() async {
    return await homeRepository.getOrders();
  }

  Future<ResponseWrapper<KitchenMenu>> getInventoryItems(
      {required int pageLimit, required int pageNumber}) async {
    return await inventoryRepository.getInventoryItems(
        pageLimit: pageLimit, pageNumber: pageNumber);
  }

  Future<ResponseWrapper<AddonItems>> getInventoryItemAddons(
      {required int kitchenMenuId,}) async {
    return await inventoryRepository.getInventoryItemAddons(
        kitchenMenuId: kitchenMenuId);
  }

  Future<ResponseWrapper<ChangeAvailabilityResponse>> changeInventoryItemAddonsAvailability(
      {required int kitchenMenuId, required int kitchenMenuAddonId, required int kitchenId, required bool status}) async {
    return await inventoryRepository.changeInventoryItemAddonsAvailability(
        kitchenMenuId: kitchenMenuId, kitchenMenuAddonId: kitchenMenuAddonId, kitchenId: kitchenId, status: status);
  }

  Future<ResponseWrapper<OrderUpdateItem>> updateOrderStatus(
      {required int orderId,
      required String orderStatus,
      int? codAmount}) async {
    return await homeRepository.updateOrderStatus(
        orderId: orderId, orderStatus: orderStatus, codAmount: codAmount);
  }

  Future<ResponseWrapper<bool>> updateOrderItemStatus({
    required int itemId,
    required int itemMenuId,
    required int orderId,
    required int orderItemStatus,
  }) async {
    return await homeRepository.updateOrderItemStatus(
      itemId: itemId,
      itemMenuId: itemMenuId,
      orderId: orderId,
      orderItemStatus: orderItemStatus,
    );
  }

  Future<ResponseWrapper<ChangeAvailabilityResponse>>
      changeInventoryItemAvailability({
    required int itemId,
    required int kitchenId,
    required int status,
    String? startDate,
    String? endDate,
  }) async {
    return await inventoryRepository.changeInventoryItemAvailability(
      itemId: itemId,
      kitchenId: kitchenId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ResponseWrapper<bool>> updateCancelOrderRequest(
      {required int orderId, required String foodPrepared}) async {
    return await homeRepository.updateCancelOrderRequest(
      orderId: orderId,
      foodPrepared: foodPrepared,
    );
  }

  Future<ResponseWrapper<bool>> confirmSpecialMessage() async {
    return await homeRepository.confirmSpecialMessage();
  }

  void updateOrderDisplayTime({required String updateUrl}) async {
    homeRepository.updateOrderDisplayTime(updateUrl: updateUrl);
  }

  Future<ResponseWrapper<String>> getQrCodeFileName() async {
    return await homeRepository.getQrCodeFileName();
  }

  Future<ResponseWrapper<bool>> deliveryGuyArrived({
    required int orderId,
  }) async {
    return await homeRepository.deliveryGuyArrived(
      orderId: orderId,
    );
  }

  Future<ResponseWrapper<bool>> temporaryCloseKitchen({
    required int duration,
  }) async {
    return await homeRepository.temporaryCloseKitchen(
      duration: duration,
    );
  }

  Future<AppVersionModel> getAppVersion() async {
    return await homeRepository.getAppVersion();
  }

  Future<ResponseWrapper<PrintReceipt>> getPrintReceiptApi({
    required int orderId,
    required String receiptType,
  }) async {
    return await homeRepository.getPrintReceiptApi(
      orderId: orderId,
      receiptType: receiptType,
    );
  }

  Future<ResponseWrapper<List<OrderHistoryDetails>>> getOrdersHistory({
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
    return await ordersHistoryRepository.getOrdersHistory(
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      pageLimit: pageLimit,
      pageNumber: pageNumber,
      orderId: orderId,
      platform: platform,
      status: status,
      sort: sort,
      export: export,
    );
  }

  Future<ResponseWrapper<List<OrderStatistics>>> getOrdersStatistics({
    required String startDate,
    required String endDate,
    required int pageLimit,
    required int pageNumber,
    String menuName = '',
    bool export = false,
  }) async {
    return await ordersStatisticsRepository.getOrdersStatistics(
      startDate: startDate,
      endDate: endDate,
      pageLimit: pageLimit,
      pageNumber: pageNumber,
      menuName: menuName,
      export: export,
    );
  }

  Future<ResponseWrapper<UndoOrderResponse>> undoOrderStatus({
    required int orderId,
  }) async {
    return await ordersHistoryRepository.undoOrderStatus(
      orderId: orderId,
    );
  }
}

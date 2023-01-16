import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:thecloud/infrastructure/apiUtil/urls.dart';
import 'package:http/http.dart' as http;
import 'package:thecloud/view/customWidgets/update_app_dialog.dart';
import 'package:thecloud/view/screens/home/widgets/alert_message_dialog.dart';
import '../util/navigation_service.dart';
import '../view/customWidgets/confirmation_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../infrastructure/catalog_facade_service.dart';
import '../infrastructure/home/model/order.dart';
import '../util/global_functions.dart';
import '../util/printing_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.catalogFacadeService});

  final CatalogFacadeService catalogFacadeService;

  List<Order>? _orders = <Order>[];

  List<Order>? get orders => _orders;
  List<Order>? _allOrders = <Order>[];

  List<Order>? get allOrders => _allOrders;
  final SplayTreeMap<String, int> _ordersSummary = SplayTreeMap<String, int>();

  SplayTreeMap<String, int> get ordersSummary => _ordersSummary;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool _isPrintKotButtonLoading = false;

  bool get isPrintKotButtonLoading => _isPrintKotButtonLoading;
  bool _isPrintCustomerButtonLoading = false;

  bool get isPrintCustomerButtonLoading => _isPrintCustomerButtonLoading;
  bool _isUpdateButtonLoading = false;

  bool get isUpdateButtonLoading => _isUpdateButtonLoading;
  bool _isDownloadButtonLoading = false;

  bool get isDownloadButtonLoading => _isDownloadButtonLoading;
  bool _isDeliveryGuyButtonLoading = false;

  bool get isDeliveryGuyButtonLoading => _isDeliveryGuyButtonLoading;
  bool _isError = false;

  bool get isError => _isError;
  bool _autoPrint = false;

  bool get autoPrint => _autoPrint;
  int _numberOfNewOrders = 0;

  int get numberOfNewOrders => _numberOfNewOrders;
  int _numberOfPreparingOrders = 0;

  int get numberOfPreparingOrders => _numberOfPreparingOrders;
  int _numberOfReadyOrders = 0;

  int get numberOfReadyOrders => _numberOfReadyOrders;

  int _counterForDisablingStatusButton = -1;
  int get counterForDisablingStatusButton => _counterForDisablingStatusButton;



  // Filter orders on status
  // 0 for all
  // 1 for new
  // 2 for preparing
  // 3 for ready
  int _filteredOrderStatus = 0;

  int get filteredOrderStatus => _filteredOrderStatus;
  int _indexForOrderStatus = -1;

  int get indexForOrderStatus => _indexForOrderStatus;
  final int _indexForKot = -1;

  int get indexForKot => _indexForKot;
  final int _indexForCustomerPrint = -1;

  int get indexForCustomerPrint => _indexForCustomerPrint;

  // Item name the orders are filtered by
  String _filteredOrdersItemName = '';

  String get filteredOrdersItemName => _filteredOrdersItemName;

  getOrders() async {
    _filteredOrdersItemName = '';
    _isLoading = true;
    _isError = false;
    _filteredOrderStatus = 0;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrders();
      checkLoginStatus(res.loginStatus!);
      _orders = res.data!.where((element) => element.validOrder!).toList();
      _allOrders = res.data!.where((element) => element.validOrder!).toList();
      _countOrders();
      _calculateOrdersSummary();
    } on DioError catch (e) {
      _isError = true;
      handleDioError(e);
    } catch (e) {
      _isError = true;
      showToast(message: e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  filterOrders(int status) {
    _filteredOrdersItemName = '';
    _filteredOrderStatus = status;
    if (status == 0) {
      _orders = _allOrders!;
    } else {
      _orders =
          _allOrders!.where((element) => element.statusId == status).toList();
    }
    notifyListeners();
  }

  _countOrders() {
    _numberOfNewOrders =
        _allOrders!.where((element) => element.statusId == 1).length;
    _numberOfPreparingOrders =
        _allOrders!.where((element) => element.statusId == 2).length;
    _numberOfReadyOrders =
        _allOrders!.where((element) => element.statusId == 3).length;
  }

  filterOrdersByItem(String itemName) {
    // To not select any filter from the statuses filters
    _filteredOrderStatus = -1;
    _filteredOrdersItemName = itemName;
    _orders = _allOrders!
        .where((element) => element.items!
            .where((element) => element.itemsDetailsName == itemName)
            .isNotEmpty)
        .toList();
    notifyListeners();
  }

  changeAutoPrintStatus() {
    _autoPrint = !_autoPrint;
    notifyListeners();
  }

  changeOrderItemCompletion({
    required int orderId,
    required int itemId,
    required int itemMenuId,
    required String itemDetails,
    required bool newValue,
  }) async {
    try {
      final res = await catalogFacadeService.updateOrderItemStatus(
        itemId: itemId,
        itemMenuId: itemMenuId,
        orderId: orderId,
        orderItemStatus: newValue ? 1 : 0,
      );
      checkLoginStatus(res.loginStatus!);
      final orderItemUpdated = res.data;
      if (orderItemUpdated!) {
        _allOrders!
            .firstWhere((element) => element.id == orderId)
            .items!
            .firstWhere((element) => element.itemId == itemId)
            .completed = newValue ? 1 : 0;
        _orders!
            .firstWhere((element) => element.id == orderId)
            .items!
            .firstWhere((element) => element.itemId == itemId)
            .completed = newValue ? 1 : 0;
        _calculateOrdersSummary();
        notifyListeners();
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  updateCancelOrderRequest(
      {required int orderId, required String foodPrepared}) async {
    try {
      final res = await catalogFacadeService.updateCancelOrderRequest(
          orderId: orderId, foodPrepared: foodPrepared);
      checkLoginStatus(res.loginStatus!);
      final cancelOrderRequestResponse = res.data;
      if (cancelOrderRequestResponse!) {
        if (_allOrders!.where((element) => element.id == orderId).isNotEmpty) {
          _allOrders!.removeAt(
              _allOrders!.indexWhere((element) => element.id == orderId));

          // _orders!.removeAt(
          //     _allOrders!.indexWhere((element) => element.id == orderId));
        }
        _countOrders();
        notifyListeners();
      } else {}
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  deliveryGuyArrived({
    required int orderId,
  }) async {
    try {
      _isDeliveryGuyButtonLoading = true;
      notifyListeners();
      final res = await catalogFacadeService.deliveryGuyArrived(
        orderId: orderId,
      );
      checkLoginStatus(res.loginStatus!);
      _allOrders!
          .firstWhere((element) => element.id == orderId)
          .riderButtonActive = false;
      _orders!
          .firstWhere((element) => element.id == orderId)
          .riderButtonActive = false;
      _isDeliveryGuyButtonLoading = false;
      notifyListeners();
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  temporayCloseKitchen({
    required int duration,
  }) async {
    try {
      final res = await catalogFacadeService.temporaryCloseKitchen(
        duration: duration,
      );
      checkLoginStatus(res.loginStatus!);
      if (res.data!) {
        showToast(message: 'kitchen closed successfully for $duration minutes');
      } else {
        showToast(message: res.message!);
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  _calculateOrdersSummary() {
    _ordersSummary.clear();
    for (int ordersIndex = 0; ordersIndex < _allOrders!.length; ordersIndex++) {
      if (_allOrders![ordersIndex].statusId == 3) {
        continue;
      }
      for (int itemsIndex = 0;
          itemsIndex < _allOrders![ordersIndex].items!.length;
          itemsIndex++) {
        if (_allOrders![ordersIndex].items![itemsIndex].completed! == 1) {
          continue;
        }
        if (_ordersSummary.containsKey(
            _allOrders![ordersIndex].items![itemsIndex].itemsDetailsName)) {
          _ordersSummary[_allOrders![ordersIndex]
              .items![itemsIndex]
              .itemsDetailsName!] = _ordersSummary[_allOrders![ordersIndex]
                  .items![itemsIndex]
                  .itemsDetailsName!]! +
              _allOrders![ordersIndex].items![itemsIndex].itemsDetailsQuantity!;
        } else {
          _ordersSummary[_allOrders![ordersIndex]
                  .items![itemsIndex]
                  .itemsDetailsName!] =
              _allOrders![ordersIndex].items![itemsIndex].itemsDetailsQuantity!;
        }
      }
    }
  }

  void periodicCheckOrders() async {
    // If there is an error don't call the check API
    if (_isError) {
      return;
    }
    try {
      var res = await catalogFacadeService.periodicCheckOrders();
      checkLoginStatus(res.loginStatus!);
      if (res.specialMessage!) {
        showDialog(
            context: NavigationService.navigatorKey.currentContext!,
            builder: (context) => AlertMessageDialog(
                  content: res.specialMessageData!,
                  confirmFunction: () {
                    confirmSpecialMessage();
                  },
                ));
      }
      var updateOrders = res.data;
      if (updateOrders!.isNotEmpty) {
        for (var i = 0; i < updateOrders.length; i++) {
          if (_allOrders!
              .where((element) => element.id == updateOrders[i].id)
              .isNotEmpty) {
            if (!updateOrders[i].validOrder!) {
              // remove order if the order status is removed now
              _allOrders!.removeAt(_allOrders!
                  .indexWhere((element) => element.id == updateOrders[i].id));
            } else {
              //update the current order when we already have that order from before
              _allOrders![_allOrders!.indexWhere(
                      (element) => element.id == updateOrders[i].id)] =
                  updateOrders[i];
              // If the order is requested for cancellation show confirmation dialog
              if (updateOrders[i].cancelledRequest == 1) {
                showDialog(
                    context: NavigationService.navigatorKey.currentContext!,
                    barrierDismissible: false,
                    builder: (context) => ConfirmationDialog(
                          content: AppLocalizations.of(context)!.the_order +
                              ' ${updateOrders[i].id} ' +
                              AppLocalizations.of(context)!
                                  .order_cancellation_message,
                          confirmFunction: () => updateCancelOrderRequest(
                              orderId: updateOrders[i].id!,
                              foodPrepared: 'yes'),
                          cancelFunction: () => updateCancelOrderRequest(
                              orderId: updateOrders[i].id!, foodPrepared: 'no'),
                        ));
              }
            }
          } else {
            //insert the order at the start of the list as it is a new order
            if (updateOrders[i].validOrder!) {
              _allOrders!.insert(0, updateOrders[i]);
              _numberOfNewOrders =
                  _allOrders!.where((element) => element.statusId == 1).length;
            }
          }
          _countOrders();
          _calculateOrdersSummary();
        }
        _orders = _allOrders;
        _filteredOrderStatus = 0;
        notifyListeners();
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  void printReceipt(
      {required int orderId,
      required String receiptType,
      bool? isEqual}) async {
    if (receiptType == 'customer') {
      _isPrintCustomerButtonLoading = true;
    } else {
      _isPrintKotButtonLoading = true;
    }
    notifyListeners();
    // const Duration(seconds: 5);
    try {
      // final res;
      final res = await catalogFacadeService.getPrintReceiptApi(
          orderId: orderId, receiptType: receiptType);
      checkLoginStatus(res.loginStatus!);
      // final receipt = res;
      // print("a: $orderId");
      final receipt = res.data;
      await PrintingService.printReceipt(
          receipt: receipt!,
          printQR: receiptType == 'customer',
          printImage: receiptType == 'customer');
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
    _isPrintKotButtonLoading = false;
    _isPrintCustomerButtonLoading = false;
    notifyListeners();
  }

  // Change the status of order from updated to not updated
  // to stop the blinking and sound and the blurred details
  void changeOrderUpdated(
    int? id,
  ) {
    _allOrders!.firstWhere((element) => element.id == id).updatedOrder = false;
    _orders!.firstWhere((element) => element.id == id).updatedOrder = false;
    notifyListeners();
  }

  indexGetting(int index) {
    _indexForOrderStatus = index;
    notifyListeners();
  }

  void updateOrderStatus(
      {required int orderId,
      required String orderStatus,
      int? codAmount}) async {
    _isUpdateButtonLoading = true;
    notifyListeners();
    try {
      final res = await catalogFacadeService.updateOrderStatus(
          orderId: orderId, orderStatus: orderStatus, codAmount: codAmount);
      checkLoginStatus(res.loginStatus!);
      final updatedOrder = res.data;
      //remove the order if the updated status is remove
      //or update the order with new details
      if (updatedOrder!.status!.toLowerCase() == 'remove') {
        _allOrders!.removeWhere((element) => element.id == updatedOrder.id);
        _orders!.removeWhere((element) => element.id == updatedOrder.id);
      } else {
        if (_filteredOrderStatus != 0) {
          _orders!.removeWhere((element) => element.id == updatedOrder.id);
        }
        _allOrders!.firstWhere((element) => element.id == updatedOrder.id)
          ..status = updatedOrder.status
          ..buttonMessage = updatedOrder.buttonMessage
          ..cardCss = updatedOrder.cardCss
          ..codAmount = updatedOrder.codAmount
          ..statusId = updatedOrder.statusId
          ..newOrder = false;
      }
      _countOrders();
      _calculateOrdersSummary();
      _startTimer();
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
    _isUpdateButtonLoading = false;
    notifyListeners();
  }

  getAppVersion() async {
    if (kIsWeb) {
      return;
    }
    try {
      final res = await catalogFacadeService.getAppVersion();
      final appVersionModel = res;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;

      int v2Number = getExtendedVersionNumber(appVersionModel.appVersion);
      int v1Number = getExtendedVersionNumber(currentAppVersion);

      /* /* bool isHigher = await isHigherThanCurrentVersion(
          appVersionModel!.appVersion, currentAppVersion); */
       */

      if (v2Number > v1Number) {
        showDialog(
            context: NavigationService.navigatorKey.currentContext!,
            builder: (context) => UpdateAppDialog(
                  confirmFunction: () async {
                    await downloadFile(
                        appVersionModel.appDownloadUrl, 'The Cloud App.apk');
                  },
                ));
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  downloadOrderInvoiceQr() async {
    try {
      _isDownloadButtonLoading = true;
      notifyListeners();
      final res = await catalogFacadeService.getQrCodeFileName();
      checkLoginStatus(res.loginStatus!);
      if (res.data != '') {
        final downloadResponse =
            await http.post(Uri.parse(Urls.kBaseUrl + Urls.downloadInvoice),
                headers: {
                  'Access-Control-Allow-Origin': '*',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode({'file_name': res.data}));
        final downloadData = downloadResponse.bodyBytes;
        saveFile(downloadData, 'order_invoice', 'PDF', MimeType.PDF);
        _isDownloadButtonLoading = false;
        showToast(
            message: AppLocalizations.of(
                    NavigationService.navigatorKey.currentContext!)!
                .file_exported_to_download);
        notifyListeners();
      } else {
        _isDownloadButtonLoading = false;
        showToast(message: res.message!);
        notifyListeners();
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  void confirmSpecialMessage() async {
    try {
      final res = await catalogFacadeService.confirmSpecialMessage();
      checkLoginStatus(res.loginStatus!);
      if (res.data!) {
      } else {
        showToast(message: res.message!);
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  void updateOrderDisplayTime(String updateUrl) async {
    try {
      catalogFacadeService.updateOrderDisplayTime(updateUrl: updateUrl);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  void clearData() {
    _orders = [];
    notifyListeners();
  }

   _startTimer() {
    _counterForDisablingStatusButton = 5;
    Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer1) {
        if (_counterForDisablingStatusButton == 0) {
            timer1.cancel();
            notifyListeners();
        } else {
          _counterForDisablingStatusButton--;
            notifyListeners();
        }
      },
    );
  }
}

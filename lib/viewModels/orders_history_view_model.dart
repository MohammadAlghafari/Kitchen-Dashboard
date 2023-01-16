import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/common/prefs_keys.dart';
import 'package:thecloud/infrastructure/ordersHistory/model/order_history_details.dart';
import 'package:thecloud/util/navigation_service.dart';

import '../infrastructure/catalog_facade_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../util/global_functions.dart';

const _itemsLimit = 20;

class OrdersHistoryViewModel extends ChangeNotifier {
  OrdersHistoryViewModel({
    required this.catalogFacadeService,
  });
  final CatalogFacadeService catalogFacadeService;

  List<OrderHistoryDetails>? _ordersHistory = <OrderHistoryDetails>[];
  List<OrderHistoryDetails>? get ordersHistory => _ordersHistory;
  SharedPreferences? sharedPreferences;

  int _pageNumber = 1;
  int get pageNumber => _pageNumber;
  String _startDate = getOnlyDate(DateTime.now());
  String get startDate => _startDate;
  String _endDate = getOnlyDate(DateTime.now());
  String get endDate => _endDate;
  String _startTime = formatTimeOfDay(TimeOfDay.now(), false);
  String get startTime => _startTime;
  String _endTime = formatTimeOfDay(TimeOfDay.now(), false);
  String get endTime => _endTime;
  String _startTimeForApi = "00:00:00";
  String get startTimeForApi => _startTimeForApi;
  String _endTimeForApi = "23:59:59";
  String get endTimeForApi => _endTimeForApi;
  String _searchedId = '';
  String get searchedId => _searchedId;
  String _searchedPlatform = '';
  String get searchedPlatform => _searchedPlatform;
  String _searchedStatus = '';
  String get searchedStatus => _searchedStatus;
  int _numberOfPages = 0;
  int get numberOfPages => _numberOfPages;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isError = false;
  bool get isError => _isError;
  String _columnId = "id";
  String _order = "desc";

  changeStartDate(String date) {
    _startDate = date;
    notifyListeners();
  }

  changeEndDate(String date) {
    _endDate = date;
    notifyListeners();
  }

  changeStartTime(String startTime) {
    _startTime = startTime;
  }

  changeEndTime(String endTime) {
    _endTime = endTime;
  }

  changeStartTimeForApi(TimeOfDay startTime) {
    _startTimeForApi = formatTimeOfDay(startTime, true);
    notifyListeners();
  }

  changeEndTimeForApi(TimeOfDay endTime) {
    _startTimeForApi = formatTimeOfDay(endTime, true);
    notifyListeners();
  }

  sortOrderHistory(String columnId, String order, ){
    _columnId = columnId;
    _order = order;
    getOrdersHistory();
    // notifyListeners();
  }

  searchOrderHistory(
      {required String orderId,
      required String platform,
      required String status,
        String? columnId,
        String? itemsOrder,
      }
      ) async {
    _pageNumber = 1;
    _searchedId = orderId;
    _searchedPlatform = platform;
    _searchedStatus = status;
    _columnId = columnId!;
    _order = itemsOrder!;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersHistory(
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTimeForApi,
        endTime: _endTimeForApi,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        orderId: _searchedId,
        platform: _searchedPlatform,
        status: _searchedStatus,
        sort: {"id": _columnId, "order": _order}
      );
      checkLoginStatus(res.loginStatus!);
      _ordersHistory = res.data!;
      _numberOfPages = (int.parse(res.totalRowCount!) / _itemsLimit).ceil();
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

  searchPage(int pageNumber, String columnId, String itemsOrder) async {
    _pageNumber = pageNumber;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersHistory(
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTimeForApi,
        endTime: _endTimeForApi,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        orderId: _searchedId,
        ///following two parameters are added on 11-12-2022.
        platform: _searchedPlatform,
        status: _searchedStatus,
        sort: {"id":columnId, "order": itemsOrder}
      );
      checkLoginStatus(res.loginStatus!);
      _ordersHistory = res.data!;
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

  getOrdersHistory() async {

    sharedPreferences = await SharedPreferences.getInstance();

    _startDate = sharedPreferences!.getString(PrefsKeys.orderHistoryStartDate) == null?
    getOnlyDate(DateTime.now()): sharedPreferences!.getString(PrefsKeys.orderHistoryStartDate).toString();
    _endDate = sharedPreferences!.getString(PrefsKeys.orderHistoryEndDate) == null?
    getOnlyDate(DateTime.now()): sharedPreferences!.getString(PrefsKeys.orderHistoryEndDate).toString();
    _startTimeForApi = sharedPreferences!.getString(PrefsKeys.orderHistoryStartTimeForApi) == null?
    "00:00:00" :sharedPreferences!.getString(PrefsKeys.orderHistoryStartTimeForApi).toString();
    _endTimeForApi = sharedPreferences!.getString(PrefsKeys.orderHistoryEndTimeForApi) == null?
    "23:59:59" :sharedPreferences!.getString(PrefsKeys.orderHistoryEndTimeForApi).toString();
    _searchedId = '';
    _searchedPlatform = '';
    _searchedStatus = '';
    _pageNumber = 1;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersHistory(
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTimeForApi,
        endTime: _endTimeForApi,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        sort: {"id": _columnId, "order": _order},
      );
      checkLoginStatus(res.loginStatus!);
      _ordersHistory = res.data!;
      _numberOfPages = (int.parse(res.totalRowCount!) / _itemsLimit).ceil();
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

  undoOrderStatus({required int orderId}) async {
    try {
      var res = await catalogFacadeService.undoOrderStatus(orderId: orderId);
      checkLoginStatus(res.loginStatus!);
      if (!res.data!.undoMessage) return;
      _ordersHistory!
          .firstWhere((element) => element.id == res.data!.orderId.toString())
        ..status = res.data!.newStatus
        ..undoStatus = res.data!.undoStatus;
    } on DioError catch (e) {
      _isError = true;
      handleDioError(e);
    } catch (e) {
      _isError = true;
      showToast(message: e.toString());
    }
    notifyListeners();
  }

  exportOrdersHistory() async {
    try {
      var res = await catalogFacadeService.getOrdersHistory(
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTime,
        endTime: _endTime,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        export: true,
      );
      checkLoginStatus(res.loginStatus!);

      var excel = Excel.createExcel();
      Sheet sheetObject = excel[excel.getDefaultSheet()!];
      sheetObject.appendRow([
        'order_id',
        'kitchen_name',
        'brand',
        'kitchen_items',
        'kitchen_total',
        'comments',
        'order_date',
        'order_time',
        'status',
        'payment'
      ]);
      for (var i = 1; i < res.data!.length + 1; i++) {
      String menu = '';
        for (var j = 0; j < res.data![i - 1].menu.length; j++) {
          menu += res.data![i - 1].menu[j].name + '\n';
        }
        sheetObject.appendRow([
          res.data![i - 1].incrementId + '( ${res.data![i - 1].platform} )',
          res.data![i - 1].kitchenName,
          res.data![i - 1].brand,
          menu,
          res.data![i - 1].totalPrice,
          res.data![i - 1].comments,
          res.data![i - 1].date,
          res.data![i - 1].time,
          res.data![i - 1].status,
          res.data![i - 1].paymentMethod,
        ]);
      }

      saveExcel(excel, 'ExportOrdersHistory');
      showToast(
          message: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .file_exported_to_download);
    } catch (e) {
      showToast(message: e.toString());
    }
  }
}

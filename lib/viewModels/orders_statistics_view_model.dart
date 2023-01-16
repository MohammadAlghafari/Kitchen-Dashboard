import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/infrastructure/ordersStatistics/model/order_statistics.dart';

import '../common/prefs_keys.dart';
import '../infrastructure/catalog_facade_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../util/global_functions.dart';
import '../util/navigation_service.dart';

const _itemsLimit = 20;

class OrdersStatisticsViewModel extends ChangeNotifier {
  OrdersStatisticsViewModel({
    required this.catalogFacadeService,
  });
  final CatalogFacadeService catalogFacadeService;

  List<OrderStatistics>? _ordersStatistics = <OrderStatistics>[];
  List<OrderStatistics>? get ordersStatistics => _ordersStatistics;
  SharedPreferences? sharedPreferences;

  int _pageNumber = 1;
  int get pageNumber => _pageNumber;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isError = false;
  bool get isError => _isError;
  String _startDate = getOnlyDate(DateTime.now());
  String get startDate => _startDate;
  String _endDate = getOnlyDate(DateTime.now());
  String get endDate => _endDate;
  String _searchedName = '';
  String get searchedName => _searchedName;
  int _numberOfPages = 0;
  int get numberOfPages => _numberOfPages;

  changeStartDate(String date) {
    _startDate = date;
  }

  changeEndDate(String date) {
    _endDate = date;
  }

  searchName(String searchName) async {
    _pageNumber = 1;
    _searchedName = searchName;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersStatistics(
        startDate: _startDate,
        endDate: _endDate,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        menuName: searchName,
      );
      checkLoginStatus(res.loginStatus!);
      _ordersStatistics = res.data!;
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

  searchPage(int pageNumber) async {
    _pageNumber = pageNumber;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersStatistics(
        startDate: _startDate,
        endDate: _endDate,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        menuName: _searchedName,
      );
      checkLoginStatus(res.loginStatus!);
      _ordersStatistics = res.data!;
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

  getOrdersStatistics() async {

    sharedPreferences = await SharedPreferences.getInstance();

    _startDate = PrefsKeys.menuStatStartDate.isEmpty?
    getOnlyDate(DateTime.now()): sharedPreferences!.getString(PrefsKeys.menuStatStartDate).toString();
    _endDate = PrefsKeys.menuStatEndDate.isEmpty?
    getOnlyDate(DateTime.now()): sharedPreferences!.getString(PrefsKeys.menuStatEndDate).toString();
    _searchedName = '';
    _pageNumber = 1;
    _isLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getOrdersStatistics(
        startDate: _startDate,
        endDate: _endDate,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
      );
      checkLoginStatus(res.loginStatus!);
      _ordersStatistics = res.data!;
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

  exportItemHistory() async {
    try {
      var res = await catalogFacadeService.getOrdersStatistics(
        startDate: _startDate,
        endDate: _endDate,
        pageLimit: _itemsLimit,
        pageNumber: _pageNumber,
        export: true,
      );
      var excel = Excel.createExcel();
      Sheet sheetObject = excel[excel.getDefaultSheet()!];
      sheetObject.appendRow(['name', 'ordered_quantity', 'kitchen_cost', 'brand', 'kitchen_name']);
      for (var i = 1; i < res.data!.length + 1; i++) {
        sheetObject.appendRow([
          res.data![i - 1].itemName,
          res.data![i - 1].itemQuantity,
          res.data![i - 1].itemPrice,
          res.data![i - 1].brand,
          res.data![i - 1].kitchenName,
        ]);
      }

      saveExcel(excel, 'ExportItemsHistory');
      showToast(
          message: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .file_exported_to_download);
    } catch (e) {
      showToast(message: e.toString());
    }
  }
}

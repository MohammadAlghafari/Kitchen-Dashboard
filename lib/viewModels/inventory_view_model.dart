import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thecloud/infrastructure/inventory/model/addon_model.dart';
import 'package:thecloud/infrastructure/inventory/model/inventory_item.dart';
import 'package:thecloud/infrastructure/inventory/model/kitchen_model.dart';
import 'package:thecloud/util/navigation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../infrastructure/catalog_facade_service.dart';
import '../util/global_functions.dart';

const _itemsLimit = 20;

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel({
    required this.catalogFacadeService,
  });

  final CatalogFacadeService catalogFacadeService;

  final List<KitchenModel> _kitchens = <KitchenModel>[];

  List<KitchenModel> get kitchens => _kitchens;

  final List<AddonModel> _addons = <AddonModel>[];

  List<AddonModel> get addons => _addons;
  List<InventoryItem>? _allInventoryItems = <InventoryItem>[];

  List<InventoryItem>? get allInventoryItems => _allInventoryItems;
  List<InventoryItem>? _inventoryItems = <InventoryItem>[];

  List<InventoryItem>? get inventoryItems => _inventoryItems;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isError = false;

  bool get isError => _isError;

  bool _isAddonsLoading = false;

  bool get isAddonsLoading => _isAddonsLoading;

  bool _hasReachedMax = false;

  bool get hasReachedMax => _hasReachedMax;
  int _pageNumber = 1;
  String _searchedName = '';

  String get searchedName => _searchedName;
  final String _searchedPrice = '';

  String get searchedPrice => _searchedPrice;
  String _searchedAvailability =
      AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!.all;

  String get searchedAvailability => _searchedAvailability;
  KitchenModel _searchedKitchen = KitchenModel(
      kitchenId: '-1',
      kitchenName:
          AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!
              .all,
      kitchenBranch: '');

  KitchenModel get searchedKitchen => _searchedKitchen;

  getInventoryItems() async {
    _isLoading = true;
    _isError = false;
    _searchedName = '';
    _searchedKitchen.kitchenId = '-1';
    _searchedAvailability =
        AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!
            .all;
    notifyListeners();
    try {
      _searchedKitchen = KitchenModel(
          kitchenId: '-1',
          kitchenName: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .all,
          kitchenBranch: '');
      //_pageNumber = 1;
      var res = await catalogFacadeService.getInventoryItems(
          pageLimit: _itemsLimit, pageNumber: _pageNumber);
      //_pageNumber += 1;
      checkLoginStatus(res.loginStatus!);
      _kitchens.clear();
      _kitchens.add(KitchenModel(
          kitchenId: '-1',
          kitchenName: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .all,
          kitchenBranch: ''));
      _kitchens.addAll(res.data!.kitchens);
      _allInventoryItems = res.data!.menuItems;
      _inventoryItems = res.data!.menuItems;
      _reachedMax(res.data!.menuItems.length);
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

  getInventoryItemAddons({
    required int kitchenMenuId,
  }) async {
    _isAddonsLoading = true;
    _isError = false;
    notifyListeners();
    try {
      var res = await catalogFacadeService.getInventoryItemAddons(
          kitchenMenuId: kitchenMenuId);
      checkLoginStatus(res.loginStatus!);
      _addons.clear();
      _addons.addAll(res.data!.addons);
    } on DioError catch (e) {
      _isError = true;
      handleDioError(e);
    } catch (e) {
      _isError = true;
      showToast(message: e.toString());
    }
    _isAddonsLoading = false;
    notifyListeners();
  }

  changeInventoryItemAddonsAvailability({
    required int kitchenMenuId,
    required int kitchenMenuAddonId,
    required int kitchenId,
    required bool status,
  }) async {
    _isError = false;
    notifyListeners();
    try {
      var res =
          await catalogFacadeService.changeInventoryItemAddonsAvailability(
              kitchenMenuId: kitchenMenuId,
              kitchenMenuAddonId: kitchenMenuAddonId,
              kitchenId: kitchenId,
              status: status);
      checkLoginStatus(res.loginStatus!);
      final changeAvailabilityResponse = res.data;
      if (changeAvailabilityResponse!.status) {
        _addons
            .firstWhere((element) =>
                element.kitchenMenuAddonsId == kitchenMenuAddonId.toString())
            .kitchenMenuAddonsStatus = status ? "1" : "0";
        notifyListeners();
      }
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

  settingStateForAvailability(String dropDown) {
    _searchedAvailability = dropDown;
    notifyListeners();
  }

  settingStateFroKitchen(KitchenModel kitchen) {
    _searchedKitchen = kitchen;
    notifyListeners();
  }

  // func(var response){
  //   _inventoryItems!.firstWhere((element) => element.id == id)
  //     .itemDetails = ;
  // print("this is called for setting state");
  // notifyListeners();
  // }
  combinedSearch(String name, KitchenModel kitchen, String dropDownValue) {
    _searchedName = name;
    _searchedKitchen = kitchen;
    _searchedAvailability = dropDownValue;
    if (_searchedName.isEmpty &&
        kitchen.kitchenId == "-1" &&
        (dropDownValue == "All" || dropDownValue == "الكل")) {
      _inventoryItems = _allInventoryItems!;
    } else if (_searchedName.isNotEmpty &&
        kitchen.kitchenId == "-1" &&
        (dropDownValue == "All" || dropDownValue == "الكل")) {
      _inventoryItems = _allInventoryItems!
          .where((element) => element.itemName
              .toLowerCase()
              .contains(_searchedName.toLowerCase()))
          .toList();
    } else if (_searchedName.isEmpty &&
        kitchen.kitchenId != "-1" &&
        (dropDownValue == "All" || dropDownValue == "الكل")) {
      _inventoryItems = _allInventoryItems!
          .where((element) => element.kitchenId.toString() == kitchen.kitchenId)
          .toList();
    } else if (_searchedName.isEmpty &&
        kitchen.kitchenId == "-1" &&
        (dropDownValue != "All" || dropDownValue != "الكل")) {
      if (_searchedAvailability == 'Available' ||
          _searchedAvailability == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) => element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) => !element.itemAvailability)
            .toList();
      }
    } else if (_searchedName.isNotEmpty &&
        kitchen.kitchenId != "-1" &&
        (dropDownValue == "All" || dropDownValue == "الكل")) {
      _inventoryItems = _allInventoryItems!
          .where((element) =>
              element.itemName
                  .toLowerCase()
                  .contains(_searchedName.toLowerCase()) &&
              element.kitchenId.toString() == kitchen.kitchenId)
          .toList();
    } else if (_searchedName.isNotEmpty &&
        kitchen.kitchenId == "-1" &&
        (dropDownValue != "All" || dropDownValue != "الكل")) {
      if (dropDownValue == 'Available' || _searchedAvailability == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName
                    .toLowerCase()
                    .contains(_searchedName.toLowerCase()) &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName
                    .toLowerCase()
                    .contains(_searchedName.toLowerCase()) &&
                !element.itemAvailability)
            .toList();
      }
    } else if (_searchedName.isEmpty &&
        kitchen.kitchenId != "-1" &&
        dropDownValue.isNotEmpty) {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems!
            .where(
                (element) => element.kitchenId.toString() == kitchen.kitchenId)
            .toList();
      } else if (dropDownValue == 'Available' ||
          _searchedAvailability == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.kitchenId.toString() == kitchen.kitchenId &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.kitchenId.toString() == kitchen.kitchenId &&
                !element.itemAvailability)
            .toList();
      }
    } else {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName
                    .toLowerCase()
                    .contains(_searchedName.toLowerCase()) &&
                element.kitchenId.toString() == kitchen.kitchenId)
            .toList();
      } else if (dropDownValue == 'Available' ||
          _searchedAvailability == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName
                    .toLowerCase()
                    .contains(_searchedName.toLowerCase()) &&
                element.kitchenId.toString() == kitchen.kitchenId &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName
                    .toLowerCase()
                    .contains(_searchedName.toLowerCase()) &&
                element.kitchenId.toString() == kitchen.kitchenId &&
                !element.itemAvailability)
            .toList();
      }
    }
    notifyListeners();
  }

  searchAvailability(String dropDownValue) {
    _searchedAvailability = dropDownValue;
    if (_searchedName.isNotEmpty && _searchedKitchen.kitchenId != '-1') {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName) &&
                element.kitchenId.toString() == _searchedKitchen.kitchenId)
            .toList();
      } else if (dropDownValue == 'Available' || dropDownValue == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName) &&
                element.kitchenId.toString() == _searchedKitchen.kitchenId &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName) &&
                element.kitchenId.toString() == _searchedKitchen.kitchenId &&
                !element.itemAvailability)
            .toList();
      }
    } else if (_searchedName.isNotEmpty && _searchedKitchen.kitchenId == '-1') {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName))
            .toList();
      } else if (dropDownValue == 'Available' || dropDownValue == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName) &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.itemName.toLowerCase().contains(_searchedName) &&
                !element.itemAvailability)
            .toList();
      }
    } else if (_searchedName.isEmpty && _searchedKitchen.kitchenId == '-1') {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems;
      } else if (dropDownValue == 'Available' || dropDownValue == 'متاح') {
        _inventoryItems = _allInventoryItems!.where((element) =>
            // element.itemName.toLowerCase().contains(_searchedName) &&
            element.itemAvailability).toList();
      } else {
        _inventoryItems = _allInventoryItems!.where((element) =>
            // element.itemName.toLowerCase().contains(_searchedName) &&
            !element.itemAvailability).toList();
      }
    } else if (_searchedName.isEmpty && _searchedKitchen.kitchenId != '-1') {
      if (dropDownValue == 'All' || dropDownValue == 'الكل') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.kitchenId.toString() == _searchedKitchen.kitchenId)
            .toList();
      } else if (dropDownValue == 'Available' || dropDownValue == 'متاح') {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.kitchenId.toString() == _searchedKitchen.kitchenId &&
                element.itemAvailability)
            .toList();
      } else {
        _inventoryItems = _allInventoryItems!
            .where((element) =>
                element.kitchenId.toString() == _searchedKitchen.kitchenId &&
                !element.itemAvailability)
            .toList();
      }
    } else if (dropDownValue == 'All' || dropDownValue == 'الكل') {
      _inventoryItems = _allInventoryItems;
    } else if (dropDownValue == 'Available' || dropDownValue == 'متاح') {
      _inventoryItems = _allInventoryItems!
          .where((element) => element.itemAvailability)
          .toList();
    } else {
      _inventoryItems = _allInventoryItems!
          .where((element) => !element.itemAvailability)
          .toList();
    }
    notifyListeners();
  }


  getInventoryItemsPagination() async {
    if (_hasReachedMax) return;
    try {
      var res = await catalogFacadeService.getInventoryItems(
          pageLimit: _itemsLimit, pageNumber: _pageNumber);
      _pageNumber += 1;
      checkLoginStatus(res.loginStatus!);
      _allInventoryItems!.addAll(res.data!.menuItems);
      _reachedMax(res.data!.menuItems.length);
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

  Future changeInventoryItemAvailability({
    required int itemId,
    required int kitchenId,
    required bool newAvailability,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final res = await catalogFacadeService.changeInventoryItemAvailability(
        itemId: itemId,
        kitchenId: kitchenId,
        status: newAvailability ? 1 : 0,
        startDate: startDate,
        endDate: endDate,
      );
      checkLoginStatus(res.loginStatus!);
      final changeAvailabilityResponse = res.data;
      if (changeAvailabilityResponse!.status) {
        _inventoryItems!.firstWhere((element) => element.id == itemId)
          ..itemAvailability =
              changeAvailabilityResponse.details.contains("Snooze")
                  ? true
                  : newAvailability
          ..itemDetails = changeAvailabilityResponse.details;
        notifyListeners();
      }
    } on DioError catch (e) {
      handleDioError(e);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  bool _reachedMax(int itemsCount) =>
      itemsCount < _itemsLimit ? _hasReachedMax = true : _hasReachedMax = false;
}

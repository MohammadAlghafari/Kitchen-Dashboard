import 'package:dio/dio.dart';
import 'package:thecloud/infrastructure/apiUtil/response_wrapper.dart';
import 'package:thecloud/infrastructure/inventory/api/change_addon_availability_api.dart';
import 'package:thecloud/infrastructure/inventory/api/change_inventory_item_availability_api.dart';
import 'package:thecloud/infrastructure/inventory/api/get_inventory_items_addons_api.dart';
import 'package:thecloud/infrastructure/inventory/api/get_inventory_items_api.dart';
import 'package:thecloud/infrastructure/inventory/inventory_interface.dart';
import 'package:thecloud/infrastructure/inventory/model/addon_items.dart';
import 'package:thecloud/infrastructure/inventory/model/kitchen_menu.dart';

import '../../common/prefs_keys.dart';
import 'model/change_availability_response.dart';

class InventoryRepository implements InventoryInterface {
  InventoryRepository({
    required this.getInventoryItemsApi,
    required this.changeInventoryItemAvailabilityApi,
    required this.getInventoryItemAddonsApi,
    required this.changeInventoryItemAddonsAvailabilityApi,
  });

  final GetInventoryItemsApi getInventoryItemsApi;
  final ChangeInventoryItemAvailabilityApi changeInventoryItemAvailabilityApi;
  final GetInventoryItemAddonsApi getInventoryItemAddonsApi;
  final ChangeInventoryItemAddonsAvailabilityApi
      changeInventoryItemAddonsAvailabilityApi;

  @override
  Future<ResponseWrapper<KitchenMenu>> getInventoryItems(
      {required int pageLimit, required int pageNumber}) async {
    Response response = await getInventoryItemsApi.getInventoryItems(
        pageLimit: pageLimit, pageNumber: pageNumber);
    var res = ResponseWrapper<KitchenMenu>();
    res.data = KitchenMenu.fromMap(response.data);
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<ChangeAvailabilityResponse>>
      changeInventoryItemAvailability({
    required int itemId,
    required int kitchenId,
    required int status,
    String? startDate,
    String? endDate,
  }) async {
    Response response = await changeInventoryItemAvailabilityApi
        .changeInventoryItemAvailability(
      itemId: itemId,
      kitchenId: kitchenId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
    var res = ResponseWrapper<ChangeAvailabilityResponse>();
    res.data =
        ChangeAvailabilityResponse.fromMap(response.data[PrefsKeys.data]);
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<AddonItems>> getInventoryItemAddons(
      {required int kitchenMenuId}) async {
    Response response = await getInventoryItemAddonsApi.getInventoryItemAddons(
        kitchenMenuId: kitchenMenuId);
    var res = ResponseWrapper<AddonItems>();
    res.data = AddonItems.fromMap(response.data);
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    res.message = response.data[PrefsKeys.message];
    return res;
  }

  @override
  Future<ResponseWrapper<ChangeAvailabilityResponse>> changeInventoryItemAddonsAvailability(
      {required int kitchenMenuId,
      required int kitchenMenuAddonId,
      required int kitchenId,
      required bool status}) async {
    Response response = await changeInventoryItemAddonsAvailabilityApi
        .changeInventoryItemAddonAvailability(
            kitchenMenuId: kitchenMenuId,
            kitchenMenuAddonId: kitchenMenuAddonId,
            kitchenId: kitchenId,
            status: status);
    var res = ResponseWrapper<ChangeAvailabilityResponse>();
    res.data = ChangeAvailabilityResponse.fromMap(response.data[PrefsKeys.data]);
    res.loginStatus = response.data[PrefsKeys.loginStatus];
    res.message = response.data[PrefsKeys.message];
    return res;
  }
}

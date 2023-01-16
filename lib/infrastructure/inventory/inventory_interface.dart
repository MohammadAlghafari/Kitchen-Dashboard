import 'package:thecloud/infrastructure/inventory/model/addon_items.dart';
import 'package:thecloud/infrastructure/inventory/model/kitchen_menu.dart';

import '../apiUtil/response_wrapper.dart';
import 'model/change_availability_response.dart';

abstract class InventoryInterface {
  Future<ResponseWrapper<KitchenMenu>> getInventoryItems(
      {required int pageLimit, required int pageNumber});

  Future<ResponseWrapper<ChangeAvailabilityResponse>> changeInventoryItemAvailability({
    required int itemId,
    required int kitchenId,
    required int status,
    String? startDate,
    String? endDate,
  });

  Future<ResponseWrapper<AddonItems>> getInventoryItemAddons(
      {required int kitchenMenuId});

  Future<ResponseWrapper<ChangeAvailabilityResponse>> changeInventoryItemAddonsAvailability({
    required int kitchenMenuId,
    required int kitchenMenuAddonId,
    required int kitchenId,
    required bool status,
  });
}

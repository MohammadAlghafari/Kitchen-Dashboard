import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class ChangeInventoryItemAddonsAvailabilityApi {
  ChangeInventoryItemAddonsAvailabilityApi({required this.dio});

  final Dio dio;

  Future<dynamic> changeInventoryItemAddonAvailability({
    required int kitchenMenuId,
    required int kitchenMenuAddonId,
    required int kitchenId,
    required bool status,
  }) async {
    final Map<String, dynamic> params = {
      'kitchen_menu_id': kitchenMenuId,
      'kitchen_menu_addon': kitchenMenuAddonId,
      'kitchen_id': kitchenId,
      'status': status? 1:0,
    };
    Response response = await dio.post(
      Urls.getAndChangeAddonItemAvailability,
      data: params,
    );
    return response;
  }
}

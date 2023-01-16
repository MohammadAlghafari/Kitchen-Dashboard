import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetInventoryItemAddonsApi {
  GetInventoryItemAddonsApi({required this.dio});

  final Dio dio;

  Future<dynamic> getInventoryItemAddons({
    required int kitchenMenuId,
  }) async {
    final Map<String, dynamic> params = {
      'kitchen_menu_id': kitchenMenuId,
    };
    Response response = await dio.post(
      Urls.getAndChangeAddonItemAvailability,
      data: params,
    );
    return response;
  }
}

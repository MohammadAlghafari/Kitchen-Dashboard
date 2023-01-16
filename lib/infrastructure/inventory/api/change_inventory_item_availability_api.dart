import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class ChangeInventoryItemAvailabilityApi {
  ChangeInventoryItemAvailabilityApi({required this.dio});

  final Dio dio;

  Future<dynamic> changeInventoryItemAvailability({
    required int itemId,
    required int kitchenId,
    required int status,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {
      'menu_id': itemId,
      'status': status,
      'kitchen_id': kitchenId,
    };
    if (startDate != null) {
      params['start_date'] = startDate;
    }
    if (endDate != null) {
      params['end_date'] = endDate;
    }

    Response response = await dio.post(
      Urls.changeInventoryItemAvailability,
      data: params,
    );
    return response;
  }
}

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetInventoryItemsApi {
  GetInventoryItemsApi({required this.dio});

  final Dio dio;

  Future<dynamic> getInventoryItems(
      {required int pageLimit, required int pageNumber}) async {
    //final param = {'page_limit': pageLimit, 'page_number': pageNumber};
    Response response = await dio.get(
      Urls.getInventoryItems,
    );
    return response;
  }
}

import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetAppVersionApi {
  GetAppVersionApi({required this.dio});


  final Dio dio;

  Future<dynamic> getAppVersion() async {
   
    Response response =
        await dio.get(Urls.getAppVersion, );
    return response;
  }
}

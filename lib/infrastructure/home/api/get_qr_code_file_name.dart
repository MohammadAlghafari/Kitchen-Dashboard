import 'package:dio/dio.dart';

import '../../apiUtil/urls.dart';

class GetQrCodeFileNameApi {
  GetQrCodeFileNameApi({required this.dio});


  final Dio dio;

  Future<dynamic> getQrCodeFileName() async {
   
    Response response =
        await dio.get(Urls.getQrCodeFileName, );
    return response;
  }
}

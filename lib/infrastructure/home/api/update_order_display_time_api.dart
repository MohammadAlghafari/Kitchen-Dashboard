import 'package:dio/dio.dart';

class UpdateOrderDisplayTimeApi {
  UpdateOrderDisplayTimeApi({required this.dio});

  final Dio dio;

  void updateOrderDisplayTime({
    required String updateUrl,
  }) async {
    await dio.post(
      '/$updateUrl',
    );
  }
}

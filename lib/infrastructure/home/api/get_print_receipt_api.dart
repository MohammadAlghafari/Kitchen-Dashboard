import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../apiUtil/urls.dart';

class GetPrintReceiptApi {
  GetPrintReceiptApi({required this.dio});

  final Dio dio;

  Future<dynamic> getPrintReceipt({
    required int orderId,
    required String receiptType,
  }) async {
    final params = {
      'order_id': orderId,
      'printTo': receiptType,
      'webTrue': kIsWeb,
      ///remove the following parameter if the KOT/Customer print aren't generating from app side.
      'pdf_type': true,
    };
    Response response = await dio.post(
      Urls.printReceipt,
      data: params,
    );
    return response;
  }
}

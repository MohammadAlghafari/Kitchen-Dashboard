import 'dart:convert';

class PrintReceipt {
  int? orderId;
  String? language;
  dynamic resultData;
  bool? pdfData;
  String? printerType;
  String? pdfType;
  String? connectionType;
  String? qrUrl;
  String? image;
  PrintReceipt({
    this.orderId,
    this.language,
    this.resultData,
    this.pdfData,
    this.printerType,
    this.pdfType,
    this.connectionType,
    this.qrUrl,
    this.image,
  });
  PrintReceipt copyWith({
    int? orderId,
    String? language,
    String? resultData,
    bool? pdfData,
    String? printerType,
    String? pdfType,
    String? connectionType,
    String? qrUrl,
    String? image,
  }) {
    return PrintReceipt(
      orderId: orderId ?? this.orderId,
      language: language ?? this.language,
      resultData: resultData ?? this.resultData,
      pdfData: pdfData ?? this.pdfData,
      printerType: printerType ?? this.printerType,
      pdfType: pdfType ?? this.pdfType,
      connectionType: connectionType ?? this.connectionType,
      qrUrl: qrUrl ?? this.qrUrl,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {

    final result = <String, dynamic>{};

    if (orderId != null) {
      result.addAll({'order_id': orderId});
    }
    if (language != null) {
      result.addAll({'language': language});
    }
    if (resultData != null) {
      result.addAll({'result_data': resultData});
    }
    if (pdfData != null) {
      result.addAll({'pdfData': pdfData});
    }
    if (pdfData != null) {
      result.addAll({'connection_type': connectionType});
    }
    if (pdfData != null) {
      result.addAll({'print_type': printerType});
    }
     if (pdfType != null) {
      result.addAll({'pdf_type': pdfType});
    }
    if (pdfData != null) {
      result.addAll({'footer_image': image});
    }
    if (pdfData != null) {
      result.addAll({'footer_qr_code': qrUrl});
    }

    return result;
  }

  factory PrintReceipt.fromMap(Map<String, dynamic> map) {
    return PrintReceipt(
      orderId: int.tryParse(map['order_id'].toString()) ?? 0,
      language: map['language'].toString() ?? '',
      resultData: map['result_data'] ?? '',
      pdfData: map['pdfData'] ?? false,
      printerType: map['print_type'].toString() ?? '',
      pdfType: map['pdf_type'].toString() ?? '',
      connectionType: map['connection_type'].toString() ?? '',
      qrUrl: map['footer_qr_code'].toString() ?? '',
      image: map['footer_image'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PrintReceipt.fromJson(String source) =>
      PrintReceipt.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PrintReceipt(orderId: $orderId, language: $language, resultData: $resultData, pdfData: $pdfData, printerType: $printerType, connectionType: $connectionType, qrUrl: $qrUrl, image: $image,)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrintReceipt &&
        other.orderId == orderId &&
        other.language == language &&
        other.resultData == resultData &&
        other.printerType == printerType &&
        other.pdfType == pdfType &&
        other.connectionType == connectionType &&
        other.qrUrl == qrUrl &&
        other.image == image &&
        other.pdfData == pdfData;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        language.hashCode ^
        resultData.hashCode ^
        printerType.hashCode ^
        pdfType.hashCode ^
        connectionType.hashCode ^
        qrUrl.hashCode ^
        image.hashCode ^
        pdfData.hashCode;
  }
}

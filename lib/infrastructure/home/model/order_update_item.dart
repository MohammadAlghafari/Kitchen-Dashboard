import 'dart:convert';

class OrderUpdateItem {
  int? id;
  int? statusId;
  String? status;
  String? buttonMessage;
  String? cardCss;
  bool? codAmount;
  OrderUpdateItem({
    this.id,
    this.statusId,
    this.status,
    this.buttonMessage,
    this.cardCss,
    this.codAmount,
  });

  OrderUpdateItem copyWith({
    int? id,
    int? statusId,
    String? status,
    String? buttonMessage,
    String? cardCss,
    bool? codAmount,
  }) {
    return OrderUpdateItem(
      id: id ?? this.id,
      statusId: statusId ?? this.statusId,
      status: status ?? this.status,
      buttonMessage: buttonMessage ?? this.buttonMessage,
      cardCss: cardCss ?? this.cardCss,
      codAmount: codAmount ?? this.codAmount,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    if(id != null){
      result.addAll({'id': id});
    }
    if(statusId != null){
      result.addAll({'status_id': statusId});
    }
    if(status != null){
      result.addAll({'status': status});
    }
    if(buttonMessage != null){
      result.addAll({'button_message': buttonMessage});
    }
    if(cardCss != null){
      result.addAll({'card_css': cardCss});
    }
    if(codAmount != null){
      result.addAll({'cod_amount': codAmount});
    }
  
    return result;
  }

  factory OrderUpdateItem.fromMap(Map<String, dynamic> map) {
    if(map.isNotEmpty) {
      return OrderUpdateItem(
      id: int.tryParse(map['id'].toString())  ?? 0,
      statusId: int.tryParse(map['status_id'].toString())  ?? 0,
      status: map['status'].toString() ?? '',
      buttonMessage: map['button_message'].toString() ?? '',
      cardCss: map['card_css'].toString() ?? '',
      codAmount: map['cod_amount'] ?? false,
    );
    } else{
      return OrderUpdateItem();
    }
  }

  String toJson() => json.encode(toMap());

  factory OrderUpdateItem.fromJson(String source) => OrderUpdateItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderUpdateItem(id: $id, statusId: $statusId, status: $status, buttonMessage: $buttonMessage, cardCss: $cardCss, codAmount: $codAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is OrderUpdateItem &&
      other.id == id &&
      other.statusId == statusId &&
      other.status == status &&
      other.buttonMessage == buttonMessage &&
      other.cardCss == cardCss &&
      other.codAmount == codAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      statusId.hashCode ^
      status.hashCode ^
      buttonMessage.hashCode ^
      cardCss.hashCode ^
      codAmount.hashCode;
  }
}

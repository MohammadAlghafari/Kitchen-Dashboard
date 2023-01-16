import 'dart:convert';

class UndoOrderResponse {
  int orderId;
  String newStatus;
  bool undoStatus;
  bool undoMessage;
  UndoOrderResponse({
    required this.orderId,
    required this.newStatus,
    required this.undoStatus,
    required this.undoMessage,
  });

  UndoOrderResponse copyWith({
    int? orderId,
    String? newStatus,
    bool? undoStatus,
    bool? undoMessage,
  }) {
    return UndoOrderResponse(
      orderId: orderId ?? this.orderId,
      newStatus: newStatus ?? this.newStatus,
      undoStatus: undoStatus ?? this.undoStatus,
      undoMessage: undoMessage ?? this.undoMessage,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'order_d': orderId});
    result.addAll({'new_status': newStatus});
    result.addAll({'undo_status': undoStatus});
    result.addAll({'undo_message': undoMessage});
  
    return result;
  }

  factory UndoOrderResponse.fromMap(Map<String, dynamic> map) {
    return UndoOrderResponse(
      orderId: int.tryParse(map['order_id'].toString())  ?? 0,
      newStatus: map['new_status'].toString() ?? '',
      undoStatus: map['undo_status'] ?? false,
      undoMessage: map['undo_message'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UndoOrderResponse.fromJson(String source) => UndoOrderResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UndoOrderResponse(orderId: $orderId, newStatus: $newStatus, undoStatus: $undoStatus, undoMessage: $undoMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UndoOrderResponse &&
      other.orderId == orderId &&
      other.newStatus == newStatus &&
      other.undoStatus == undoStatus &&
      other.undoMessage == undoMessage;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
      newStatus.hashCode ^
      undoStatus.hashCode ^
      undoMessage.hashCode;
  }
}

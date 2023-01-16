import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:thecloud/infrastructure/ordersHistory/model/order_history_details_menu.dart';

class OrderHistoryDetails {
  String id;
  String incrementId;
  String comments;
  String date;
  String time;
  String status;
  String brand;
  String kitchenName;
  String platform;
  String? paymentMethod;
  bool undoStatus;
  List<OrderHistoryDetailsMenu> menu;
  double totalPrice;
  OrderHistoryDetails({
    required this.id,
    required this.incrementId,
    required this.comments,
    required this.date,
    required this.time,
    required this.status,
    required this.brand,
    required this.kitchenName,
    required this.platform,
    required this.paymentMethod,
    required this.menu,
    required this.totalPrice,
    required this.undoStatus,
  });

  OrderHistoryDetails copyWith({
    String? id,
    String? incrementId,
    String? comments,
    String? date,
    String? time,
    String? status,
    String? brand,
    String? kitchenName,
    String? platform,
    String? paymentMethod,
    bool? undoStatus,
    List<OrderHistoryDetailsMenu>? menu,
    double? totalPrice,
  }) {
    return OrderHistoryDetails(
      id: id ?? this.id,
      incrementId: incrementId ?? this.incrementId,
      comments: comments ?? this.comments,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      brand: brand ?? this.brand,
      kitchenName: kitchenName ?? this.kitchenName,
      platform: platform ?? this.platform,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      undoStatus: undoStatus ?? this.undoStatus,
      menu: menu ?? this.menu,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'increment_id': incrementId});
    result.addAll({'comments': comments});
    result.addAll({'date': date});
    result.addAll({'time': time});
    result.addAll({'status': status});
    result.addAll({'brand': brand});
    result.addAll({'kitchenName': kitchenName});
    result.addAll({'platform': platform});
    result.addAll({'paymentMethod': paymentMethod});
    result.addAll({'undoStatus': undoStatus});
    result.addAll({'menu': menu.map((x) => x.toMap()).toList()});
    result.addAll({'Total_price': totalPrice});

    return result;
  }

  factory OrderHistoryDetails.fromMap(Map<String, dynamic> map) {
    return OrderHistoryDetails(
      id: map['id'].toString() ?? '',
      incrementId: map['increment_id'].toString() ?? '',
      comments: map['comments'].toString() ?? '',
      date: map['date'].toString() ?? '',
      time: map['time'].toString() ?? '',
      status: map['status'].toString() ?? '',
      brand: map['brand'].toString() ?? '',
      kitchenName: map['kitchen_name'].toString() ?? '',
      platform: map['platform'].toString() ?? '',
      paymentMethod: map['payment_method'].toString() ?? '',
      undoStatus: map['undo_status'] ?? false,
      menu: map['menu'] != null
          ? List<OrderHistoryDetailsMenu>.from(
              map['menu']?.map((x) => OrderHistoryDetailsMenu.fromMap(x)))
          : [],
      totalPrice: double.tryParse(map['Total_price'].toString()) ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderHistoryDetails.fromJson(String source) =>
      OrderHistoryDetails.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderHistoryDetails(id: $id, increamentId: $incrementId, comments: $comments, date: $date, time: $time, status: $status, brand: $brand, platform: $platform, menu: $menu, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderHistoryDetails &&
        other.id == id &&
        other.incrementId == incrementId &&
        other.comments == comments &&
        other.date == date &&
        other.time == time &&
        other.status == status &&
        other.brand == brand &&
        other.platform == platform &&
        listEquals(other.menu, menu) &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        incrementId.hashCode ^
        comments.hashCode ^
        date.hashCode ^
        time.hashCode ^
        status.hashCode ^
        brand.hashCode ^
        platform.hashCode ^
        menu.hashCode ^
        totalPrice.hashCode;
  }
}

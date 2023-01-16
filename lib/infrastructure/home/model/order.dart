import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'order_item.dart';

class Order {
  int? id;
  int? statusId;
  String? kitchenName;
  String? kitchenBranch;
  String? incrementId;
  String? status;
  String? buttonMessage;
  String? cardCss;
  String? customerName;
  String? brandName;
  String? orderDate;
  String? orderTime;
  String? platformName;
  String? pickupTime;
  String? pickupBy;
  String? estimstedDriverDuration;
  String? riderName;
  String? riderPhone;
  String? estimatedDistance;
  String? comments;
  String? displayUrl;
  bool? codAmount;
  bool? newOrder;
  bool? updatedOrder;
  bool? validOrder;
  bool? samePlatform;
  String? updatedOrderMessage;
  int? cancelledRequest;
  bool? riderButtonActive;
  bool? customerAlreadyprinted;
  List<OrderItem>? items;
  Order({
    this.id,
    this.statusId,
    this.kitchenName,
    this.kitchenBranch,
    this.incrementId,
    this.status,
    this.buttonMessage,
    this.cardCss,
    this.customerName,
    this.brandName,
    this.orderDate,
    this.orderTime,
    this.platformName,
    this.pickupTime,
    this.pickupBy,
    this.estimatedDistance,
    this.estimstedDriverDuration,
    this.riderName,
    this.riderPhone,
    this.comments,
    this.displayUrl,
    this.codAmount,
    this.newOrder,
    this.updatedOrder,
    this.validOrder,
    this.samePlatform,
    this.updatedOrderMessage,
    this.cancelledRequest,
    this.riderButtonActive,
    this.customerAlreadyprinted,
    this.items,
  });

  Order copyWith({
    int? id,
    int? statusId,
    String? kitchenName,
    String? kitchenBranch,
    String? incrementId,
    String? status,
    String? buttonMessage,
    String? cardCss,
    String? customerName,
    String? brandName,
    String? orderDate,
    String? orderTime,
    String? platformName,
    String? pickupTime,
    String? pickupBy,
    String? estimstedDriverDuration,
    String? riderName,
    String? riderPhone,
    String? estimatedDistance,
    String? comments,
    String? displayUrl,
    bool? codAmount,
    bool? newOrder,
    bool? updatedOrder,
    bool? validOrder,
    bool? samePlatform,
    String? updatedOrderMessage,
    int? cancelledRequest,
    bool? riderButtonActive,
    bool? customerAlreadyprinted,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      statusId: statusId ?? this.statusId,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenBranch: kitchenBranch ?? this.kitchenBranch,
      incrementId: incrementId ?? this.incrementId,
      status: status ?? this.status,
      buttonMessage: buttonMessage ?? this.buttonMessage,
      cardCss: cardCss ?? this.cardCss,
      customerName: customerName ?? this.customerName,
      brandName: brandName ?? this.brandName,
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
      platformName: platformName ?? this.platformName,
      pickupTime: pickupTime ?? this.pickupTime,
      pickupBy: pickupBy ?? this.pickupBy,
      estimstedDriverDuration:
          estimstedDriverDuration ?? this.estimstedDriverDuration,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      comments: comments ?? this.comments,
      displayUrl: displayUrl ?? this.displayUrl,
      codAmount: codAmount ?? this.codAmount,
      newOrder: newOrder ?? this.newOrder,
      updatedOrder: updatedOrder ?? this.updatedOrder,
      validOrder: validOrder ?? this.validOrder,
      samePlatform: samePlatform ?? this.samePlatform,
      updatedOrderMessage: updatedOrderMessage ?? this.updatedOrderMessage,
      cancelledRequest: cancelledRequest ?? this.cancelledRequest,
      riderButtonActive: riderButtonActive ?? this.riderButtonActive,
      customerAlreadyprinted:
          customerAlreadyprinted ?? this.customerAlreadyprinted,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (statusId != null) {
      result.addAll({'status_id': statusId});
    }
    if (kitchenName != null) {
      result.addAll({'kitchen_name': kitchenName});
    }
    if (kitchenBranch != null) {
      result.addAll({'kitchen_branch': kitchenBranch});
    }
    if (incrementId != null) {
      result.addAll({'increment_id': incrementId});
    }
    if (status != null) {
      result.addAll({'status': status});
    }
    if (buttonMessage != null) {
      result.addAll({'button_message': buttonMessage});
    }
    if (cardCss != null) {
      result.addAll({'card_css': cardCss});
    }
    if (customerName != null) {
      result.addAll({'customer_name': customerName});
    }
    if (brandName != null) {
      result.addAll({'brand_name': brandName});
    }
    if (orderDate != null) {
      result.addAll({'order_date': orderDate});
    }
    if (orderTime != null) {
      result.addAll({'order_time': orderTime});
    }
    if (platformName != null) {
      result.addAll({'platform_name': platformName});
    }
    if (pickupTime != null) {
      result.addAll({'pickup_time': pickupTime});
    }
    if (pickupBy != null) {
      result.addAll({'pickup_by': pickupBy});
    }
    if (estimatedDistance != null) {
      result.addAll({'estimated_distance': estimatedDistance});
    }
    if (estimstedDriverDuration != null) {
      result.addAll({'estimated_driver_duration': estimstedDriverDuration});
    }
    if (riderName != null) {
      result.addAll({'rider_name': riderName});
    }
    if (riderPhone != null) {
      result.addAll({'rider_phone': riderPhone});
    }
    if (comments != null) {
      result.addAll({'comments': comments});
    }
    if (displayUrl != null) {
      result.addAll({'display_url': displayUrl});
    }
    if (codAmount != null) {
      result.addAll({'cod_amount': codAmount});
    }
    if (newOrder != null) {
      result.addAll({'new_order': newOrder});
    }
    if (samePlatform != null) {
      result.addAll({'same_platform': samePlatform});
    }
    if (updatedOrder != null) {
      result.addAll({'update_message_value': updatedOrder});
    }
    if (validOrder != null) {
      result.addAll({'valid_in_dashboard': validOrder});
    }
    if (updatedOrderMessage != null) {
      result.addAll({'update_message': updatedOrderMessage});
    }
    if (cancelledRequest != null) {
      result.addAll({'cancelled_request': cancelledRequest});
    }
    if (riderButtonActive != null) {
      result.addAll({'rider_arrived_button': riderButtonActive});
    }
    if (customerAlreadyprinted != null) {
      result.addAll({'customer_already_printed': customerAlreadyprinted});
    }
    if (items != null) {
      result.addAll({'items': items!.map((x) => x.toMap()).toList()});
    }

    return result;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    if (map.isNotEmpty) {
      return Order(
        id: int.tryParse(map['id'].toString()) ?? 0,
        statusId: int.tryParse( map['status_id'].toString())?? 0,
        kitchenName: map['kitchen_name'].toString() ?? '',
        kitchenBranch: map['kitchen_branch'].toString() ?? '',
        incrementId: map['increment_id'].toString() ?? '',
        status: map['status'].toString() ?? '',
        buttonMessage: map['button_message'].toString() ?? '',
        cardCss: map['card_css'].toString() ?? '',
        customerName: map['customer_name'].toString() ?? '',
        brandName: map['brand_name'].toString() ?? '',
        orderDate: map['order_date'].toString() ?? '',
        orderTime: map['order_time'].toString() ?? '',
        platformName: map['platform_name'].toString() ?? '',
        pickupTime: map['pickup_time'].toString() ?? '',
        pickupBy: map['pickup_by'].toString() ?? '',
        estimstedDriverDuration: map['estimated_driver_duration'].toString() ?? '',
        riderName: map['rider_name'].toString() ?? '',
        riderPhone: map['rider_phone'].toString() ?? '',
        estimatedDistance: map['estimated_distance'].toString() ?? '',
        comments: map['comments'].toString() ?? '',
        displayUrl: map['display_url'].toString() ?? '',
        codAmount: map['cod_amount'] ?? false,
        newOrder: map['new_order'] ?? false,
        updatedOrder: map['update_message_value'] ?? false,
        validOrder: map['valid_in_dashboard'] ?? true,
        samePlatform: map['same_platform'] ?? false,
        updatedOrderMessage: map['update_message'].toString() ?? '',
        cancelledRequest: int.tryParse(map['cancelled_request'].toString()) ?? 0,
        riderButtonActive: map['rider_arrived_button'] ?? true,
        customerAlreadyprinted: map['customer_already_printed'] ?? false,
        items: map['items'] != null
            ? List<OrderItem>.from(
                map['items']?.map((x) => OrderItem.fromMap(x)))
            : [],
      );
    } else {
      return Order();
    }
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(id: $id, statusId: $statusId, kitchenName: $kitchenName, kitchenBranch: $kitchenBranch, incrementId: $incrementId, status: $status, buttonMessage: $buttonMessage, cardCss: $cardCss, customerName: $customerName, brandName: $brandName, orderDate: $orderDate, orderTime: $orderTime, platformName: $platformName, pickupTime: $pickupTime, pickupBy: $pickupBy, comments: $comments, codAmount: $codAmount, newOrder: $newOrder, updatedOrder: $updatedOrder, validOrder: $validOrder, updatedOrderMessage: $updatedOrderMessage, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        other.statusId == statusId &&
        other.kitchenName == kitchenName &&
        other.kitchenBranch == kitchenBranch &&
        other.incrementId == incrementId &&
        other.status == status &&
        other.buttonMessage == buttonMessage &&
        other.cardCss == cardCss &&
        other.customerName == customerName &&
        other.brandName == brandName &&
        other.orderDate == orderDate &&
        other.orderTime == orderTime &&
        other.platformName == platformName &&
        other.pickupTime == pickupTime &&
        other.pickupBy == pickupBy &&
        other.comments == comments &&
        other.displayUrl == displayUrl &&
        other.codAmount == codAmount &&
        other.newOrder == newOrder &&
        other.updatedOrder == updatedOrder &&
        other.validOrder == validOrder &&
        other.updatedOrderMessage == updatedOrderMessage &&
        other.cancelledRequest == cancelledRequest &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        statusId.hashCode ^
        kitchenName.hashCode ^
        kitchenBranch.hashCode ^
        incrementId.hashCode ^
        status.hashCode ^
        buttonMessage.hashCode ^
        cardCss.hashCode ^
        customerName.hashCode ^
        brandName.hashCode ^
        orderDate.hashCode ^
        orderTime.hashCode ^
        platformName.hashCode ^
        pickupTime.hashCode ^
        pickupBy.hashCode ^
        comments.hashCode ^
        codAmount.hashCode ^
        newOrder.hashCode ^
        updatedOrder.hashCode ^
        validOrder.hashCode ^
        updatedOrderMessage.hashCode ^
        cancelledRequest.hashCode ^
        items.hashCode;
  }
}

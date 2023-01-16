import 'dart:convert';

class OrderStatistics {
  String itemName;
  String itemQuantity;
  String itemPrice;
  String brand;
  String kitchenName;
  OrderStatistics({
    required this.itemName,
    required this.itemQuantity,
    required this.itemPrice,
    required this.brand,
    required this.kitchenName,
  });

  OrderStatistics copyWith({
    String? itemName,
    String? itemQuantity,
    String? itemPrice,
    String? brand,
    String? kitchenName,
  }) {
    return OrderStatistics(
      itemName: itemName ?? this.itemName,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      itemPrice: itemPrice ?? this.itemPrice,
      brand: brand ?? this.brand,
      kitchenName: kitchenName ?? this.kitchenName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'item_name': itemName});
    result.addAll({'quantity': itemQuantity});
    result.addAll({'total_cost': itemPrice});
    result.addAll({'brand_name': brand});
    result.addAll({'kitchen_name': kitchenName});

    return result;
  }

  factory OrderStatistics.fromMap(Map<String, dynamic> map) {
    return OrderStatistics(
      itemName: map['item_name'].toString() ?? '',
      itemQuantity: map['quantity'].toString() ?? '',
      itemPrice: map['total_cost'].toString() ?? '',
      brand: map['brand_name'].toString() ?? '',
      kitchenName: map['kitchen_name'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderStatistics.fromJson(String source) =>
      OrderStatistics.fromMap(json.decode(source));
      
  @override
  String toString() =>
      'OrderStatistics(itemName: $itemName, itemQuantity: $itemQuantity, itemPrice: $itemPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderStatistics &&
        other.itemName == itemName &&
        other.itemQuantity == itemQuantity &&
        other.itemPrice == itemPrice;
  }

  @override
  int get hashCode =>
      itemName.hashCode ^ itemQuantity.hashCode ^ itemPrice.hashCode;
}

import 'dart:convert';

class InventoryItem {
  int id;
  String category;
  int kitchenId;
  String itemName;
  String itemPrice;
  String kitchenBranch;
  String kitchenName;
  bool itemAvailability;
  String itemDetails;
  InventoryItem({
    required this.id,
    required this.category,
    required this.kitchenId,
    required this.itemName,
    required this.itemPrice,
    required this.itemAvailability,
    required this.kitchenBranch,
    required this.kitchenName,
    required this.itemDetails,
  });

  InventoryItem copyWith({
    int? id,
    String? category,
    int? kitchenId,
    String? itemName,
    String? itemPrice,
    String? kitchenBranch,
    String? kitchenName,
    bool? itemAvailability,
    String? itemDetails,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      category: category ?? this.category,
      kitchenId: kitchenId ?? this.kitchenId,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      kitchenBranch: kitchenBranch ?? this.kitchenBranch,
      kitchenName: kitchenName ?? this.kitchenName,
      itemAvailability: itemAvailability ?? this.itemAvailability,
      itemDetails: itemDetails ?? this.itemDetails,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'kitchen_menu_kitchen_menu_id': id});
    result.addAll({'kitchen_menu_category': category});
    result.addAll({'kitchen_menu_kitchen_id': kitchenId});
    result.addAll({'kitchen_menu_name': itemName});
    result.addAll({'kitchen_menu_buy_price': itemPrice});
    result.addAll({'kitchen_branch': kitchenBranch});
    result.addAll({'kitchen_name': kitchenName});
    result.addAll({'kitchen_menu_available': itemAvailability});
    result.addAll({'item_details': itemDetails});

    return result;
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: int.tryParse(map['kitchen_menu_kitchen_menu_id'].toString())  ?? 0,
      category: map['kitchen_menu_category'].toString() ?? '',
      kitchenId: int.tryParse(map['kitchen_menu_kitchen_id'].toString())  ?? 0,
      itemName: map['kitchen_menu_name'].toString() ?? '',
      itemPrice: map['kitchen_menu_buy_price'].toString() ?? '0.0',
      kitchenBranch: map['kitchen_branch'].toString() ?? '',
      kitchenName: map['kitchen_name'].toString() ?? '',
      itemDetails: map['item_details'].toString() ?? '',
      itemAvailability: map['kitchen_menu_available'] != null &&
             int.tryParse(map['kitchen_menu_available'].toString())  == 1
          ? true
          : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryItem.fromJson(String source) =>
      InventoryItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InventoryItem(id: $id, itemName: $itemName, itemPrice: $itemPrice, itemAvailability: $itemAvailability)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InventoryItem &&
        other.id == id &&
        other.itemName == itemName &&
        other.itemPrice == itemPrice &&
        other.itemAvailability == itemAvailability;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        itemName.hashCode ^
        itemPrice.hashCode ^
        itemAvailability.hashCode;
  }
}

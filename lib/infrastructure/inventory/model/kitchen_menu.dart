import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:thecloud/infrastructure/inventory/model/inventory_item.dart';
import 'package:thecloud/infrastructure/inventory/model/kitchen_model.dart';

class KitchenMenu {
  List<InventoryItem> menuItems;
  List<KitchenModel> kitchens;
  KitchenMenu({
    required this.menuItems,
    required this.kitchens,
  });

  KitchenMenu copyWith({
    List<InventoryItem>? menuItems,
    List<KitchenModel>? kitchens,
  }) {
    return KitchenMenu(
      menuItems: menuItems ?? this.menuItems,
      kitchens: kitchens ?? this.kitchens,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'menuItems': menuItems.map((x) => x.toMap()).toList()});
    result.addAll({'kitchens': kitchens.map((x) => x.toMap()).toList()});

    return result;
  }

  factory KitchenMenu.fromMap(Map<String, dynamic> map) {
    return KitchenMenu(
      menuItems: List<InventoryItem>.from(map['data']?.map((x) => InventoryItem.fromMap(x))),
      kitchens: List<KitchenModel>.from(map['kitchen_name']?.map((x) => KitchenModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory KitchenMenu.fromJson(String source) => KitchenMenu.fromMap(json.decode(source));

  @override
  String toString() => 'KitchenMenu(menuItems: $menuItems, kitchens: $kitchens)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is KitchenMenu &&
      listEquals(other.menuItems, menuItems) &&
      listEquals(other.kitchens, kitchens);
  }

  @override
  int get hashCode => menuItems.hashCode ^ kitchens.hashCode;
}

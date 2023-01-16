import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderItem {
  int? itemId;
  int? itemMenuId;
  String? itemsDetails;
  String? itemsDetailsName;
  String? itemsDetailsCategory;
  int? itemsDetailsQuantity;
  List<String>? addonDetails;
  List<AddOnsWithCategory>? addOnsWithCategory;
  int? completed;
  OrderItem({
    this.itemId,
    this.itemMenuId,
    this.itemsDetails,
    this.itemsDetailsName,
    this.itemsDetailsCategory,
    this.itemsDetailsQuantity,
    this.addonDetails,
    this.completed,
    this.addOnsWithCategory,
  });

  OrderItem copyWith({
    int? itemId,
    int? itemMenuId,
    String? itemsDetails,
    String? itemsDetailsName,
    String? itemsDetailsCategory,
    int? itemsDetailsQuantity,
    List<String>? addonDetails,
    List<AddOnsWithCategory>? addOnsWithCategory,
    int? completed,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      itemMenuId: itemMenuId ?? this.itemMenuId,
      itemsDetails: itemsDetails ?? this.itemsDetails,
      itemsDetailsName: itemsDetailsName ?? this.itemsDetailsName,
      itemsDetailsCategory: itemsDetailsCategory ?? this.itemsDetailsCategory,
      itemsDetailsQuantity: itemsDetailsQuantity ?? this.itemsDetailsQuantity,
      addonDetails: addonDetails ?? this.addonDetails,
      addOnsWithCategory: addOnsWithCategory ?? this.addOnsWithCategory,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (itemId != null) {
      result.addAll({'item_id': itemId});
    }
    if (itemMenuId != null) {
      result.addAll({'item_menu_id': itemMenuId});
    }
    if (itemsDetails != null) {
      result.addAll({'items_details': itemsDetails});
    }
    if (itemsDetailsName != null) {
      result.addAll({'items_details_name': itemsDetailsName});
    }
    if (itemsDetailsCategory != null) {
      result.addAll({'items_details_category': itemsDetailsCategory});
    }
    if (itemsDetailsQuantity != null) {
      result.addAll({'items_details_quantity': itemsDetailsQuantity});
    }
    if (addonDetails != null) {
      result.addAll({'addon_details': addonDetails});
    }
    if (addOnsWithCategory != null) {
      result.addAll({'addon_with_category': addOnsWithCategory});
    }
    if (completed != null) {
      result.addAll({'items_status': completed});
    }

    return result;
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    List<AddOnsWithCategory> addOns = [];
    if (map['addon_with_category'] != null &&
        map['addon_with_category'] is Map<String, dynamic>) {
      (map['addon_with_category'] as Map<String, dynamic>)
          .keys
          .toList()
          .forEach((element) {
        addOns.add(AddOnsWithCategory(
            category: element,
            addOns: List<AddOn>.from(map['addon_with_category'][element]
                ?.map((x) => AddOn.fromMap(x)))));
      });
    }
    return OrderItem(
      itemId: int.tryParse(map['item_id'].toString()) ?? 0,
      itemMenuId: int.tryParse(map['item_menu_id'].toString()) ?? 0,
      itemsDetails: map['items_details'].toString() ?? '',
      itemsDetailsName: map['items_details_name'].toString() ?? '',
      itemsDetailsCategory: map['items_details_category'].toString() ?? '',
      itemsDetailsQuantity:
          int.tryParse(map['items_details_quantity'].toString()) ?? 0,
      completed: int.tryParse(map['items_status'].toString()) ?? 0,
      addonDetails: map['addon_details'] != null
          ? List<String>.from(map['addon_details'])
          : [],
      addOnsWithCategory: addOns,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));

  @override
  String toString() =>
      'OrderItem(itemId: $itemId, itemsDetails: $itemsDetails, addonDetails: $addonDetails)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderItem &&
        other.itemId == itemId &&
        other.completed == completed &&
        other.itemsDetails == itemsDetails &&
        listEquals(other.addonDetails, addonDetails);
  }

  @override
  int get hashCode =>
      itemId.hashCode ^ itemsDetails.hashCode ^ addonDetails.hashCode;
}

class AddOnsWithCategory {
  String category;
  List<AddOn> addOns;
  AddOnsWithCategory({
    required this.category,
    required this.addOns,
  });

  AddOnsWithCategory copyWith({
    String? category,
    List<AddOn>? addOns,
  }) {
    return AddOnsWithCategory(
      category: category ?? this.category,
      addOns: addOns ?? this.addOns,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'category': category});
    result.addAll({'addOns': addOns.map((x) => x.toMap()).toList()});

    return result;
  }

  factory AddOnsWithCategory.fromMap(Map<String, dynamic> map) {
    return AddOnsWithCategory(
      category: map['category'].toString() ?? '',
      addOns: List<AddOn>.from(map['addOns']?.map((x) => AddOn.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory AddOnsWithCategory.fromJson(String source) =>
      AddOnsWithCategory.fromMap(json.decode(source));

  @override
  String toString() =>
      'AddOnsWithCategory(category: $category, addOns: $addOns)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddOnsWithCategory &&
        other.category == category &&
        listEquals(other.addOns, addOns);
  }

  @override
  int get hashCode => category.hashCode ^ addOns.hashCode;
}

class AddOn {
  int id;
  String name;
  int quantity;
  AddOn({
    required this.id,
    required this.name,
    required this.quantity,
  });

  AddOn copyWith({
    int? id,
    String? name,
    int? quantity,
  }) {
    return AddOn(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'quantity': quantity});

    return result;
  }

  factory AddOn.fromMap(Map<String, dynamic> map) {
    return AddOn(
      id: int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'].toString() ?? '',
      quantity: int.tryParse(map['quantity'].toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddOn.fromJson(String source) => AddOn.fromMap(json.decode(source));

  @override
  String toString() => 'AddOn(id: $id, name: $name, quantity: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddOn &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ quantity.hashCode;
}

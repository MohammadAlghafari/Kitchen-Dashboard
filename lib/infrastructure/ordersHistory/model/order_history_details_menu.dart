import 'dart:convert';

class OrderHistoryDetailsMenu {
  int id;
  String name;
  String category;
  int quantity;
  String addOn;
  int price;
  OrderHistoryDetailsMenu({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.addOn,
    required this.price,
  });

  OrderHistoryDetailsMenu copyWith({
    int? id,
    String? name,
    String? category,
    int? quantity,
    String? addOn,
    int? price,
  }) {
    return OrderHistoryDetailsMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      addOn: addOn ?? this.addOn,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'category': category});
    result.addAll({'quantity': quantity});
    result.addAll({'addOn': addOn});
    result.addAll({'price': price});
  
    return result;
  }

  factory OrderHistoryDetailsMenu.fromMap(Map<String, dynamic> map) {
    return OrderHistoryDetailsMenu(
      id: int.tryParse(map['id'].toString())  ?? 0,
      name: map['name'].toString() ?? '',
      category: map['category'].toString() ?? '',
      quantity: int.tryParse(map['quantity'].toString() ) ?? 0,
      addOn: map['addon'].toString() ?? '',
      price: int.tryParse(map['price'].toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderHistoryDetailsMenu.fromJson(String source) => OrderHistoryDetailsMenu.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderHistoryDetailsMenu(id: $id, name: $name, category: $category, quantity: $quantity, addOn: $addOn, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is OrderHistoryDetailsMenu &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.quantity == quantity &&
      other.addOn == addOn &&
      other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      quantity.hashCode ^
      addOn.hashCode ^
      price.hashCode;
  }
}

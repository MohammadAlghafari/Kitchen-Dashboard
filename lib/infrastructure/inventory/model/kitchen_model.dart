import 'dart:convert';

class KitchenModel {
  String kitchenId;
  String kitchenName;
  String kitchenBranch;
  KitchenModel({
    required this.kitchenId,
    required this.kitchenName,
    required this.kitchenBranch,
  });

  KitchenModel copyWith({
    String? kitchenId,
    String? kitchenName,
    String? kitchenBranch,
  }) {
    return KitchenModel(
      kitchenId: kitchenId ?? this.kitchenId,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenBranch: kitchenBranch ?? this.kitchenBranch,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'kitchens_id': kitchenId});
    result.addAll({'kitchens_name': kitchenName});
    result.addAll({'kitchens_branches': kitchenBranch});

    return result;
  }

  factory KitchenModel.fromMap(Map<String, dynamic> map) {
    return KitchenModel(
      kitchenId: map['kitchens_id'].toString() ?? '',
      kitchenName: map['kitchens_name'].toString() ?? '',
      kitchenBranch: map['kitchens_branches'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory KitchenModel.fromJson(String source) =>
      KitchenModel.fromMap(json.decode(source));

  @override
  String toString() => kitchenName + ' ' + kitchenBranch;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KitchenModel &&
        other.kitchenId == kitchenId &&
        other.kitchenName == kitchenName;
  }

  @override
  int get hashCode => kitchenId.hashCode ^ kitchenName.hashCode;
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:thecloud/infrastructure/inventory/model/addon_model.dart';

class AddonItems {
  List<AddonModel> addons;
  AddonItems({
    required this.addons,
  });

  AddonItems copyWith({
    List<AddonModel>? addons,
  }) {
    return AddonItems(
      addons: addons ?? this.addons,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'addons': addons.map((x) => x.toMap()).toList()});

    return result;
  }

  factory AddonItems.fromMap(Map<String, dynamic> map) {
    return AddonItems(
      addons: List<AddonModel>.from(map['data']?.map((x) => AddonModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory AddonItems.fromJson(String source) => AddonItems.fromMap(json.decode(source));

  @override
  String toString() => 'AddonItems(addons: $addons)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddonItems &&
        listEquals(other.addons, addons);
  }

  @override
  int get hashCode => addons.hashCode;
}

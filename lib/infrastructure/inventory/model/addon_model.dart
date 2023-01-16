// // To parse this JSON data, do
// //
// //     final addonModel = addonModelFromJson(jsonString);
//
// import 'dart:convert';
//
// AddonModel? addonModelFromJson(String str) => AddonModel.fromJson(json.decode(str));
//
// String addonModelToJson(AddonModel? data) => json.encode(data!.toJson());
//
// class AddonModel {
//   AddonModel({
//     this.data,
//     this.message,
//     this.loginStatus,
//   });
//
//   List<Map<String, String?>?>? data;
//   String? message;
//   bool? loginStatus;
//
//   factory AddonModel.fromJson(Map<String, dynamic> json) => AddonModel(
//     data: json["data"] == null ? [] : List<Map<String, String?>?>.from(json["data"]!.map((x) => Map.from(x!).map((k, v) => MapEntry<String, String?>(k, v)))),
//     message: json["message"],
//     loginStatus: json["login_status"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "data": data == null ? [] : List<dynamic>.from(data!.map((x) => Map.from(x!).map((k, v) => MapEntry<String, dynamic>(k, v)))),
//     "message": message,
//     "login_status": loginStatus,
//   };
// }


// import 'dart:convert';
//
// // import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:thecloud/infrastructure/inventory/model/addon_model.dart';
//
// import 'package:thecloud/infrastructure/inventory/model/inventory_item.dart';
// import 'package:thecloud/infrastructure/inventory/model/kitchen_model.dart';
//
// class Addon {
//   List<AddonModel> addonItems;
//   String message;
//   // List<AddonModel> addons;
//   Addon({
//     required this.menuItems,
//     required this.kitchens,
//     // required this.addons,
//   });
//
//   Addon copyWith({
//     List<InventoryItem>? menuItems,
//     List<KitchenModel>? kitchens,
//     // List<AddonModel>? addons,
//   }) {
//     return Addon(
//       menuItems: menuItems ?? this.menuItems,
//       kitchens: kitchens ?? this.kitchens,
//       // addons: addons ?? this.addons,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};
//
//     result.addAll({'menuItems': menuItems.map((x) => x.toMap()).toList()});
//     result.addAll({'kitchens': kitchens.map((x) => x.toMap()).toList()});
//     // result.addAll({'addons': addons.map((x) => x.toMap()).toList()});
//
//     return result;
//   }
//
//   factory Addon.fromMap(Map<String, dynamic> map) {
//     return Addon(
//       menuItems: List<InventoryItem>.from(map['data']?.map((x) => InventoryItem.fromMap(x))),
//       kitchens: List<KitchenModel>.from(map['kitchen_name']?.map((x) => KitchenModel.fromMap(x))),
//       // addons: List<AddonModel>.from(map['data']?.map((x) => AddonModel.fromMap(x))),
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory Addon.fromJson(String source) => Addon.fromMap(json.decode(source));
//
//   @override
//   String toString() => 'KitchenMenu(menuItems: $menuItems, kitchens: $kitchens)';
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is Addon &&
//         listEquals(other.menuItems, menuItems) &&
//         listEquals(other.kitchens, kitchens);
//   }
//
//   @override
//   int get hashCode => menuItems.hashCode ^ kitchens.hashCode;
// }
//
//
import 'dart:convert';

class AddonModel {
  String kitchenMenuAddonsId;
  String kitchenMenuAddonsName;
  String kitchenMenuAddonsBuyPrice;
  String kitchenMenuAddonsKitchenId;
  String kitchenMenuAddonsNameLang1;
  String kitchenMenuAddonsCategory;
  String kitchenMenuAddonsCategoryLang1;
  String kitchenMenuKitchenMenuId;
  String kitchenMenuName;
  String kitchenMenuBuyPrice;
  String kitchenMenuKitchenId;
  String kitchenMenuAvailable;
  String kitchenMenuNameLang1;
  String kitchenMenuCategories;
  String kitchenMenuCategoryLang1;
  String kitchensId;
  String kitchensName;
  String kitchensBranches;
  String kitchenMenuAddonsStatus;
  AddonModel({
    required this.kitchenMenuAddonsId,
    required this.kitchenMenuAddonsName,
    required this.kitchenMenuAddonsBuyPrice,
    required this.kitchenMenuAddonsKitchenId,
    required this.kitchenMenuAddonsNameLang1,
    required this.kitchenMenuAddonsCategory,
    required this.kitchenMenuAddonsCategoryLang1,
    required this.kitchenMenuKitchenMenuId,
    required this.kitchenMenuName,
    required this.kitchenMenuBuyPrice,
    required this.kitchenMenuKitchenId,
    required this.kitchenMenuAvailable,
    required this.kitchenMenuNameLang1,
    required this.kitchenMenuCategories,
    required this.kitchenMenuCategoryLang1,
    required this.kitchensId,
    required this.kitchensName,
    required this.kitchensBranches,
    required this.kitchenMenuAddonsStatus,
  });

  AddonModel copyWith({
    String? kitchenMenuAddonsId,
    String? kitchenMenuAddonsName,
    String? kitchenMenuAddonsBuyPrice,
    String? kitchenMenuAddonsKitchenId,
    String? kitchenMenuAddonsNameLang1,
    String? kitchenMenuAddonsCategory,
    String? kitchenMenuAddonsCategoryLang1,
    String? kitchenMenuKitchenMenuId,
    String? kitchenMenuName,
    String? kitchenMenuBuyPrice,
    String? kitchenMenuKitchenId,
    String? kitchenMenuAvailable,
    String? kitchenMenuNameLang1,
    String? kitchenMenuCategories,
    String? kitchenMenuCategoryLang1,
    String? kitchensId,
    String? kitchensName,
    String? kitchensBranches,
    String? kitchenMenuAddonsStatus,
  }) {
    return AddonModel(
      kitchenMenuAddonsId: kitchenMenuAddonsId ?? this.kitchenMenuAddonsId,
      kitchenMenuAddonsName: kitchenMenuAddonsName ?? this.kitchenMenuAddonsName,
      kitchenMenuAddonsBuyPrice: kitchenMenuAddonsBuyPrice ?? this.kitchenMenuAddonsBuyPrice,
      kitchenMenuAddonsKitchenId: kitchenMenuAddonsKitchenId ?? this.kitchenMenuAddonsKitchenId,
      kitchenMenuAddonsNameLang1: kitchenMenuAddonsNameLang1 ?? this.kitchenMenuAddonsNameLang1,
      kitchenMenuAddonsCategory: kitchenMenuAddonsCategory ?? this.kitchenMenuAddonsCategory,
      kitchenMenuAddonsCategoryLang1: kitchenMenuAddonsCategoryLang1 ?? this.kitchenMenuAddonsCategoryLang1,
      kitchenMenuKitchenMenuId: kitchenMenuKitchenMenuId ?? this.kitchenMenuKitchenMenuId,
      kitchenMenuName: kitchenMenuName ?? this.kitchenMenuName,
      kitchenMenuBuyPrice: kitchenMenuBuyPrice ?? this.kitchenMenuBuyPrice,
      kitchenMenuKitchenId: kitchenMenuKitchenId ?? this.kitchenMenuKitchenId,
      kitchenMenuAvailable: kitchenMenuAvailable ?? this.kitchenMenuAvailable,
      kitchenMenuNameLang1: kitchenMenuNameLang1 ?? this.kitchenMenuNameLang1,
      kitchenMenuCategories: kitchenMenuCategories ?? this.kitchenMenuCategories,
      kitchenMenuCategoryLang1: kitchenMenuCategoryLang1 ?? this.kitchenMenuCategoryLang1,
      kitchensId: kitchensId ?? this.kitchensId,
      kitchensName: kitchensName ?? this.kitchensName,
      kitchensBranches: kitchensBranches ?? this.kitchensBranches,
      kitchenMenuAddonsStatus: kitchenMenuAddonsStatus ?? this.kitchenMenuAddonsStatus,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'kitchen_menu_addons_id': kitchenMenuAddonsId});
    result.addAll({'kitchen_menu_addons_name': kitchenMenuAddonsName});
    result.addAll({'kitchen_menu_addons_buy_price': kitchenMenuAddonsBuyPrice});
    result.addAll({'kitchen_menu_addons_kitchen_id': kitchenMenuAddonsKitchenId});
    result.addAll({'kitchen_menu_addons_name_lang1': kitchenMenuAddonsNameLang1});
    result.addAll({'kitchen_menu_addons_category': kitchenMenuAddonsCategory});
    result.addAll({'kitchen_menu_addons_category_lang1': kitchenMenuAddonsCategoryLang1});
    result.addAll({'kitchen_menu_kitchen_menu_id': kitchenMenuKitchenMenuId});
    result.addAll({'kitchen_menu_name': kitchenMenuName});
    result.addAll({'kitchen_menu_buy_price': kitchenMenuBuyPrice});
    result.addAll({'kitchen_menu_kitchen_id': kitchenMenuKitchenId});
    result.addAll({'kitchen_menu_available': kitchenMenuAvailable});
    result.addAll({'kitchen_menu_name_lang1': kitchenMenuNameLang1});
    result.addAll({'kitchen_menu_categories': kitchenMenuCategories});
    result.addAll({'kitchen_menu_category_lang1': kitchenMenuCategoryLang1});
    result.addAll({'kitchens_id': kitchensId});
    result.addAll({'kitchens_name': kitchensName});
    result.addAll({'kitchens_branches': kitchensBranches});
    result.addAll({'kitchen_menu_addons_status': kitchenMenuAddonsStatus});

    return result;
  }

  factory AddonModel.fromMap(Map<String, dynamic> map) {
    return AddonModel(
      kitchenMenuAddonsId: map['kitchen_menu_addons_id'].toString() ?? '',
      kitchenMenuAddonsName: map['kitchen_menu_addons_name'].toString() ?? '',
      kitchenMenuAddonsBuyPrice: map['kitchen_menu_addons_buy_price'].toString() ?? '',
      kitchenMenuAddonsKitchenId: map['kitchen_menu_addons_kitchen_id'].toString() ?? '',
      kitchenMenuAddonsNameLang1: map['kitchen_menu_addons_name_lang1'].toString() ?? '',
      kitchenMenuAddonsCategory: map['kitchen_menu_addons_category'].toString() ?? '',
      kitchenMenuAddonsCategoryLang1: map['kitchen_menu_addons_category_lang1'].toString() ?? '',
      kitchenMenuKitchenMenuId: map['kitchen_menu_kitchen_menu_id'].toString() ?? '',
      kitchenMenuName: map['kitchen_menu_name'].toString() ?? '',
      kitchenMenuBuyPrice: map['kitchen_menu_buy_price'].toString() ?? '',
      kitchenMenuKitchenId: map['kitchen_menu_kitchen_id'].toString() ?? '',
      kitchenMenuAvailable: map['kitchen_menu_available'].toString() ?? '',
      kitchenMenuNameLang1: map['kitchen_menu_name_lang1'].toString() ?? '',
      kitchenMenuCategories: map['kitchen_menu_categories'].toString() ?? '',
      kitchenMenuCategoryLang1: map['kitchen_menu_category_lang1'].toString() ?? '',
      kitchensId: map['kitchens_id'].toString() ?? '',
      kitchensName: map['kitchens_name'].toString() ?? '',
      kitchensBranches: map['kitchens_branches'].toString() ?? '',
      kitchenMenuAddonsStatus: map['kitchen_menu_addons_status'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AddonModel.fromJson(String source) =>
      AddonModel.fromMap(json.decode(source));

  @override
  String toString() => kitchenMenuAddonsId + ' ' + kitchensId + ' ' + kitchenMenuAddonsName + ' ' + kitchenMenuAddonsCategory + ' ' + kitchenMenuAddonsStatus;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddonModel &&
        other.kitchenMenuAddonsId == kitchenMenuAddonsId &&
        other.kitchenMenuAddonsBuyPrice == kitchenMenuAddonsBuyPrice &&
        // other.kitchenMenuAddonsId == kitchenMenuAddonsId &&
        other.kitchenMenuAddonsKitchenId == kitchenMenuAddonsKitchenId;
  }

  @override
  int get hashCode => kitchenMenuAddonsId.hashCode ^ kitchenMenuAddonsKitchenId.hashCode;
}

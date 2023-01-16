import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../common/colors.dart';
import '../../../../viewModels/inventory_view_model.dart';
import '../../../../viewModels/settings_view_model.dart';
import '../../../customWidgets/loading_icon_widget.dart';
import '../../../customWidgets/no_data_widget.dart';
import '../../../customWidgets/server_error_widget.dart';

// ignore: must_be_immutable
class AddonsDialog extends StatefulWidget {
  AddonsDialog(
      {Key? key,
      required this.content,
      required this.itemId,
      required this.itemName,
      this.cancelFunction})
      : super(key: key);
  final String content;
  final String itemName;
  final int itemId;
  Function? cancelFunction;

  @override
  State<AddonsDialog> createState() => _AddonsDialogState();
}

class _AddonsDialogState extends State<AddonsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<InventoryViewModel>(context, listen: false)
            .getInventoryItemAddons(kitchenMenuId: widget.itemId));
  }

  @override
  Widget build(BuildContext context) {
    var languageCode = Provider.of<SettingsViewModel>(context, listen: true)
        .setting
        .mobileLanguage
        .languageCode;
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Wrap(
        spacing: 10,
        children: <Widget>[
          // Icon(Icons.add, color: MyColors.green,),
          Text(
            widget.itemName + ' ' + _trans.add_ons,
            style: TextStyle(
                color: MyColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          const Divider(),
        ],
      ),
      content: SizedBox(
        height: kIsWeb ? 350 : 300,
        width: kIsWeb ? 400 : 350,
        child: Consumer<InventoryViewModel>(
          builder: (context, inventoryViewModel, child) {
            return inventoryViewModel.isAddonsLoading
                ? const LoadingIconWidget()
                : inventoryViewModel.isError
                    ? SizedBox(
                        height: 70,
                        width: 70,
                        child: ServerErrorWidget(
                          onTap: () =>
                              inventoryViewModel.getInventoryItemAddons(
                                  kitchenMenuId: widget.itemId),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            inventoryViewModel.getInventoryItemAddons(
                                kitchenMenuId: widget.itemId),
                        color: MyColors.green,
                        child: Column(
                          children: [
                            inventoryViewModel.addons.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: NoDataWidget(
                                          onTap: () => inventoryViewModel
                                              .getInventoryItemAddons(
                                                  kitchenMenuId: widget.itemId),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _trans.add_ons.split(":")[0],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _trans.category,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _trans.status,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: kIsWeb ? 280 : 230,
                                        child: ListView.builder(
                                          itemBuilder: (context, index) => index >=
                                                      inventoryViewModel
                                                          .addons.length &&
                                                  inventoryViewModel
                                                      .searchedName
                                                      .isEmpty /* &&
                                                            inventoryViewModel
                                                                .searchedPrice.isEmpty */
                                                  &&
                                                  inventoryViewModel
                                                          .searchedAvailability ==
                                                      _trans.available
                                              ? const LoadingIconWidget()
                                              : Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: 80,
                                                          child: Text(languageCode ==
                                                                      'ar' &&
                                                                  inventoryViewModel
                                                                          .addons[
                                                                              index]
                                                                          .kitchenMenuAddonsNameLang1
                                                                          .toString() !=
                                                                      "null"
                                                              ? inventoryViewModel
                                                                  .addons[index]
                                                                  .kitchenMenuAddonsNameLang1
                                                              : inventoryViewModel
                                                                  .addons[index]
                                                                  .kitchenMenuAddonsName),
                                                        ),
                                                        SizedBox(
                                                          width: 80,
                                                          child: Text(languageCode ==
                                                                      'ar' &&
                                                                  inventoryViewModel
                                                                          .addons[
                                                                              index]
                                                                          .kitchenMenuAddonsCategoryLang1
                                                                          .toString() !=
                                                                      "null"
                                                              ? inventoryViewModel
                                                                  .addons[index]
                                                                  .kitchenMenuAddonsCategoryLang1
                                                              : inventoryViewModel
                                                                  .addons[index]
                                                                  .kitchenMenuAddonsCategory),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          child: Switch(
                                                            activeColor:
                                                                MyColors.green,
                                                            value: inventoryViewModel
                                                                        .addons[
                                                                            index]
                                                                        .kitchenMenuAddonsStatus ==
                                                                    "1"
                                                                ? true
                                                                : false,
                                                            onChanged: (value) {
                                                              // if (!value) {
                                                              inventoryViewModel.changeInventoryItemAddonsAvailability(
                                                                  kitchenMenuId: int.parse(inventoryViewModel
                                                                      .addons[
                                                                          index]
                                                                      .kitchenMenuKitchenMenuId
                                                                      .toString()),
                                                                  kitchenMenuAddonId:
                                                                      int.parse(
                                                                          inventoryViewModel.addons[index].kitchenMenuAddonsId
                                                                              .toString()),
                                                                  kitchenId: int.parse(inventoryViewModel
                                                                      .addons[
                                                                          index]
                                                                      .kitchensId
                                                                      .toString()),
                                                                  status: value
                                                                      ? true
                                                                      : false);
                                                              //   showDialog(
                                                              //       context: context,
                                                              //       builder: (context) => MenuItemAvailabilityDialog(
                                                              //         itemId: inventoryItem.id,
                                                              //         kitchenId: inventoryItem.kitchenId,
                                                              //         newStatus: value,
                                                              //       ));
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),
                                          itemCount:
                                              inventoryViewModel.addons.length,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      );
          },
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
    );
  }
}

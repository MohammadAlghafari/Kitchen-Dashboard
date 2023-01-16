import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:thecloud/common/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thecloud/infrastructure/inventory/model/inventory_item.dart';
import 'package:thecloud/view/customWidgets/confirmation_dialog.dart';
import 'package:thecloud/view/screens/inventory/widgets/addons_dialog.dart';
import 'package:thecloud/viewModels/inventory_view_model.dart';

import '../../../../util/global_functions.dart';
import 'menu_item_availability_dialog.dart';

class InventoryItemListItem extends StatefulWidget {
   InventoryItemListItem({Key? key, required this.inventoryItem, required this.inventoryViewModel, required this.index})
      : super(key: key);

  final InventoryItem inventoryItem;
  final InventoryViewModel inventoryViewModel;
  final int index;

  @override
  State<InventoryItemListItem> createState() => _InventoryItemListItemState();
}

class _InventoryItemListItemState extends State<InventoryItemListItem> {
  final GlobalKey _one = GlobalKey();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
    (_) => ShowCaseWidget.of(context)
        .startShowCase([_one,]));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // ShowCaseWidget.of(context).dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return  Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Flexible(fit: FlexFit.tight,
              child: GestureDetector(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (context) => AddonsDialog(
                        content: _trans
                            .are_you_sure_you_want_to_change_item_availability,
                        itemName: widget.inventoryItem.itemName,
                        itemId: widget.inventoryItem.id,
                      ));
                },
                child: widget.indeqx == 0? Showcase(
                  description: _trans.click_item_name_to_see_the_addons,
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //       color: MyColors.newOrderColor,
                  //       width: 2.00
                  //   ),
                  // ),
                  key: _one,
                  child: Text(widget.inventoryItem.itemName,),
                ):
                Text(widget.inventoryItem.itemName,),
              ),
            ),
            const SizedBox(
              width: kIsWeb? 10: 20,
            ),
            if(kIsWeb)
              Flexible(fit: FlexFit.tight, child: Text(widget.inventoryItem.category)),
            // SizedBox(
            //     width: 150,
            //     child: Text(inventoryItem.category)),
            // const SizedBox(
            //   width: 20,
            // ),
            SizedBox(
                width: kIsWeb ? null : 100,
                child: Text(
                    widget.inventoryItem.kitchenName + ' ' + widget.inventoryItem.kitchenBranch)),
            if (isTablet)
              const SizedBox(
                width: 50,
              ),
            if (isTablet)
              SizedBox(
                  width: 300,
                  child: Text(
                    widget.inventoryItem.itemDetails,
                    textAlign: TextAlign.center,
                  )),
            const Spacer(),
            Switch(
              activeColor: MyColors.green,
              value: widget.inventoryItem.itemAvailability,
              onChanged: (value) {
                if (!value) {
                  showDialog(
                      context: context,
                      builder: (context) => MenuItemAvailabilityDialog(
                        itemId: widget.inventoryItem.id,
                        kitchenId: widget.inventoryItem.kitchenId,
                        newStatus: value,
                      ));
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        content: _trans
                            .are_you_sure_you_want_to_change_item_availability,
                        confirmFunction: () {
                          Provider.of<InventoryViewModel>(context,
                              listen: false)
                              .changeInventoryItemAvailability(
                            itemId: widget.inventoryItem.id,
                            kitchenId: widget.inventoryItem.kitchenId,
                            newAvailability: value,
                          );
                        },
                      ));
                }
              },
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        );
      }
  }

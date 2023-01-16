import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/infrastructure/ordersHistory/model/order_history_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thecloud/util/global_functions.dart';
import 'package:thecloud/viewModels/orders_history_view_model.dart';

import '../../../../common/colors.dart';
import '../../../customWidgets/confirmation_dialog.dart';

class OrderHistoryListItem extends StatelessWidget {
  const OrderHistoryListItem({Key? key, required this.orderHistoryModel})
      : super(key: key);

  final OrderHistoryDetails orderHistoryModel;
  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    String menu = '';
    for (var i = 0; i < orderHistoryModel.menu.length; i++) {
      menu += orderHistoryModel.menu[i].name + '\n';
    }

    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        SizedBox(
            width: isTablet ? 70 : 40,
            child: Text(orderHistoryModel.incrementId)),
        const SizedBox(
          width: 20,
        ),
        Flexible(fit: FlexFit.tight, child: Text(menu)),
        const SizedBox(
          width: 20,
        ),
        if (isTablet)
          SizedBox(width: 100, child: Text(orderHistoryModel.kitchenName)),
        if (isTablet)
          const SizedBox(
            width: 40,
          ),
        if (isTablet)
          SizedBox(width: 100, child: Text(orderHistoryModel.brand)),
        if (isTablet)
          const SizedBox(
            width: 20,
          ),
        SizedBox(
            width: 40,
            child: Text(orderHistoryModel.totalPrice.toStringAsFixed(2))),
       
          const SizedBox(
            width: 20,
          ),
        SizedBox(
            width: isTablet ? 100 : 70,
            child: Text(
              orderHistoryModel.status,
              textAlign: TextAlign.center,
            )),
        if (isTablet)
          const SizedBox(
            width: 20,
          ),
        if (isTablet)
          SizedBox(
              width: 40,
              child: Text(
                orderHistoryModel.paymentMethod!,
                textAlign: TextAlign.center,
              )),
        SizedBox(
          width: isTablet ? 45 : 17,
        ),
        if (orderHistoryModel.undoStatus)
          InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                        content:
                            _trans.are_you_sure_you_want_to_change_order_status,
                        confirmFunction: () {
                          Provider.of<OrdersHistoryViewModel>(context,
                                  listen: false)
                              .undoOrderStatus(
                                  orderId: int.parse(orderHistoryModel.id));
                        }));
              },
              child: Container(
                  padding: const EdgeInsets.all(1),
                  color: MyColors.preparingOrderColor,
                  child: Text((_trans.undo))))
        else
          const SizedBox(
            width: 35,
          ),

        /*  ElevatedButton(
              child: Text((_trans.undo)),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                        content:
                            _trans.are_you_sure_you_want_to_change_order_status,
                        confirmFunction: () {
                          Provider.of<OrdersHistoryViewModel>(context,
                                  listen: false)
                              .undoOrderStatus(
                                  orderId: int.parse(orderHistoryModel.id));
                        }));
              },
              style: ElevatedButton.styleFrom(
                  primary: MyColors.preparingOrderColor)), */
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

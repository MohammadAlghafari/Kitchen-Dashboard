import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/common/colors.dart';
import '../../../../viewModels/home_view_model.dart';

class OrdersItemsSummaryDrawer extends StatelessWidget {
  const OrdersItemsSummaryDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return Drawer(child:
        Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
      List<Widget> ordersSummary = [];
      homeViewModel.ordersSummary.forEach((key, value) {
        ordersSummary.add(InkWell(
          onTap: () {
            homeViewModel.filterOrdersByItem(key);
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(key)),
                    Text('$value', style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ));
      });
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              _trans.orders_summary,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: ordersSummary,
            ),
          ],
        ),
      );
    }));
  }
}

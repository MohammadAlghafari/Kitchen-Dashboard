import 'package:flutter/material.dart';
import 'package:thecloud/infrastructure/ordersStatistics/model/order_statistics.dart';

import '../../../../util/global_functions.dart';

class ItemStatisticsListItem extends StatelessWidget {
  const ItemStatisticsListItem({Key? key, required this.itemStatistics})
      : super(key: key);

  final OrderStatistics itemStatistics;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        Flexible(fit: FlexFit.tight, child: Text(itemStatistics.itemName)),
        if (isTablet)
          SizedBox(
              width: 150,
              child: Text(
                itemStatistics.kitchenName,
                textAlign: TextAlign.center,
              )),
        if (isTablet)
          const SizedBox(
            width: 50,
          ),
        if (isTablet)
          SizedBox(
              width: 100,
              child: Text(
                itemStatistics.brand,
                textAlign: TextAlign.center,
              )),
        if (isTablet)
          const SizedBox(
            width: 55,
          ),
        Text(itemStatistics.itemQuantity.toString()),
        const SizedBox(
          width: 75,
        ),
        SizedBox(
            width: 60,
            child: Text(
              double.parse(itemStatistics.itemPrice).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
      ],
    );
  }
}

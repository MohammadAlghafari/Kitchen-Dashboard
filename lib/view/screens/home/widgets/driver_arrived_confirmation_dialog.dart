import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common/colors.dart';

// ignore: must_be_immutable
class DriverArrivedConfirmationDialog extends StatelessWidget {
  DriverArrivedConfirmationDialog(
      {Key? key,
      required this.estimatedDistance,
      required this.estimatedDuration,
      required this.driverName,
      required this.driverPhone,
      required this.confirmFunction,
      required this.buttonEnabled,
      required this.samePlatform,
      this.cancelFunction})
      : super(key: key);
  final String estimatedDuration;
  final String estimatedDistance;
  final String driverName;
  final String driverPhone;
  final Function confirmFunction;
  final bool buttonEnabled;
  final bool samePlatform;
  Function? cancelFunction;

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.report, color: MyColors.green),
          Text(
            _trans.rider_details,
            style: TextStyle(color: MyColors.green),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            samePlatform
                ? driverName + ' ' + _trans.rider_will_pick_order
                : _trans.driver_name + driverName,
          ),
          if (!samePlatform)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _trans.driver_phone + driverPhone,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _trans.estimated_distance + estimatedDistance,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _trans.estimated_duration + estimatedDuration,
                ),
              ],
            ),
          if (buttonEnabled)
            const SizedBox(
              height: 25,
            ),
          if (buttonEnabled)
            Text(
              _trans.are_you_sure_the_driver_has_arrived,
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.close,
            style: TextStyle(color: MyColors.green),
          ),
          onPressed: () {
            if (cancelFunction != null) {
              cancelFunction!();
            }
            Navigator.of(context).pop();
          },
        ),
        if (buttonEnabled)
          TextButton(
            child: Text(
              _trans.yes,
              style: TextStyle(color: MyColors.green),
            ),
            onPressed: () {
              confirmFunction();
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}

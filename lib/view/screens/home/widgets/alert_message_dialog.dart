import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common/colors.dart';

// ignore: must_be_immutable
class AlertMessageDialog extends StatelessWidget {
  const AlertMessageDialog({
    Key? key,
    required this.confirmFunction,
    required this.content,
  }) : super(key: key);
  final Function confirmFunction;
  final String content;

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.info, color: MyColors.green),
          Text(
            _trans.alert,
            style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.okay,
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

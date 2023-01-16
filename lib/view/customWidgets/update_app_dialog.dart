import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/colors.dart';

class UpdateAppDialog extends StatelessWidget {
  const UpdateAppDialog({
    Key? key,
    required this.confirmFunction,
  }) : super(key: key);

  final Function confirmFunction;

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        children: <Widget>[
          Icon(Icons.celebration, size: 40, color: MyColors.green),
          const SizedBox(
            height: 10,
          ),
          Text(
            _trans.update,
            style: TextStyle(color: MyColors.green, fontSize: 24),
          ),
        ],
      ),
      content: Text(
        _trans.app_version_update_message,
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.close,
            style: TextStyle(color: MyColors.green),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            _trans.update,
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

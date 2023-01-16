import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/colors.dart';

// ignore: must_be_immutable
class ConfirmationDialog extends StatelessWidget {
  ConfirmationDialog(
      {Key? key,
      required this.content,
      required this.confirmFunction,
      this.cancelFunction})
      : super(key: key);
  final String content;
  final Function confirmFunction;
  Function? cancelFunction;

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.info, color: MyColors.green,),
          Text(
            _trans.confirmation,
            style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],
      ),
      content: Text(content),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.no,
            style: TextStyle(color: MyColors.paleRed, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (cancelFunction != null) {
              cancelFunction!();
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            _trans.yes,
            style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),
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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/viewModels/home_view_model.dart';
import '../../common/colors.dart';

class CloseKitchenDialog extends StatefulWidget {
  const CloseKitchenDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<CloseKitchenDialog> createState() => _CloseKitchenDialogState();
}

class _CloseKitchenDialogState extends State<CloseKitchenDialog> {
  String chosenDuration = '15';

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
            _trans.confirmation,
            style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),
          ),
          const Divider()
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_trans.close_kitchen_duration),
          const SizedBox(
            height: 10,
          ),
          DropdownButton(
            value: chosenDuration,
            items: ['15', '30', '45', '60']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            underline: Container(
              height: 1.0,
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1.0))),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
            ),
            onChanged: (selected) {
              setState(() {
                chosenDuration = selected.toString();
              });
            },
            isExpanded: true,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.cancel,
            style: TextStyle(color: MyColors.green, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            _trans.close_kitchen,
            style: TextStyle(color: MyColors.paleRed, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Provider.of<HomeViewModel>(context, listen: false)
                .temporayCloseKitchen(duration: int.parse(chosenDuration));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

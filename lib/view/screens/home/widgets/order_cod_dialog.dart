import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../common/colors.dart';
import '../../../../viewModels/home_view_model.dart';
import '../../../../viewModels/settings_view_model.dart';

class OrderCodDialog extends StatefulWidget {
  const OrderCodDialog({Key? key, required this.orderId, required this.status})
      : super(key: key);
  final int orderId;
  final String status;

  @override
  State<OrderCodDialog> createState() => _OrderCodDialogState();
}

class _OrderCodDialogState extends State<OrderCodDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codAmountController = TextEditingController();

  @override
  void dispose() {
    codAmountController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<SettingsViewModel>(context, listen: false)
            .setting
            .brightness ==
        Brightness.dark;
    final _trans = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: isDark ? MyColors.backgroundLevel0 : MyColors.white,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(_trans.please_insert_cash_amount_to_be_collected),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: codAmountController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                cursorColor: MyColors.green,
                decoration: InputDecoration(
                  hintText: _trans.amount,
                  hintStyle: const TextStyle(fontSize: 13),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: MyColors.green,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: MyColors.green,
                    ),
                  ),
                ),
                validator: (amount) {
                  return amount!.trim().isEmpty
                      ? _trans.this_field_cant_be_empty
                      : null;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<HomeViewModel>(context, listen: false)
                        .updateOrderStatus(
                            orderId: widget.orderId,
                            orderStatus: widget.status,
                            codAmount: int.tryParse(codAmountController.text)
                            );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(_trans.okay),
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.green,
                    minimumSize: const Size.fromHeight(35)))
          ],
        ),
      ),
    );
  }
}

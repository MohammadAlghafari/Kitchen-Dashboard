import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/util/global_functions.dart';
import '../../../../common/colors.dart';
import '../../../../viewModels/inventory_view_model.dart';
import '../../../customWidgets/drop_down_text_field.dart';

class MenuItemAvailabilityDialog extends StatefulWidget {
  const MenuItemAvailabilityDialog({
    Key? key,
    required this.itemId,
    required this.kitchenId,
    required this.newStatus,
  }) : super(key: key);
  final int itemId;
  final int kitchenId;
  final bool newStatus;

  @override
  State<MenuItemAvailabilityDialog> createState() =>
      _MenuItemAvailabilityDialogState();
}

class _MenuItemAvailabilityDialogState
    extends State<MenuItemAvailabilityDialog> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int selectedDaysRadio = 1;
  bool dateFieldsHidden = true;
  InventoryViewModel? inventoryViewModel;

  @override
  void initState() {
    startDateController = TextEditingController();
    endDateController =
        TextEditingController(text: getOnlyDate(DateTime.now()) + ' 11:59 PM');
    super.initState();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startDateController.text =
        getOnlyDate(DateTime.now()) + ' ' + TimeOfDay.now().format(context);
    final _trans = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.report, color: MyColors.green),
          Text(
            _trans.confirmation,
            style: TextStyle(color: MyColors.green),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Radio(
                  visualDensity: const VisualDensity(horizontal: -4),
                  value: 1,
                  groupValue: selectedDaysRadio,
                  onChanged: (value) {
                    setState(() {
                      selectedDaysRadio = 1;
                      dateFieldsHidden = true;
                      startDate = DateTime.now();
                      endDate = DateTime.now();
                      startDateController.text = getOnlyDate(startDate) +
                          ' ' +
                          TimeOfDay.now().format(context);
                      endDateController.text =
                          getOnlyDate(endDate) + ' 11:59 PM';
                    });
                  }),
              Text(
                '1 ${_trans.day}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 20,
              ),
              Radio(
                  visualDensity: const VisualDensity(horizontal: -4),
                  value: 2,
                  groupValue: selectedDaysRadio,
                  onChanged: (value) {
                    setState(() {
                      selectedDaysRadio = 2;
                      dateFieldsHidden = true;
                      startDate = DateTime.now();
                      endDate = DateTime.now().add(const Duration(days: 2));
                      startDateController.text = getOnlyDate(startDate) +
                          ' ' +
                          TimeOfDay.now().format(context);
                      endDateController.text =
                          getOnlyDate(endDate) + ' 11:59 PM';
                    });
                  }),
              Text(
                '3 ${_trans.days}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          Row(
            children: [
              Radio(
                  visualDensity: const VisualDensity(horizontal: -4),
                  value: 3,
                  groupValue: selectedDaysRadio,
                  onChanged: (value) {
                    setState(() {
                      selectedDaysRadio = 3;
                      dateFieldsHidden = true;
                      startDate = DateTime.now();
                      endDate = DateTime.now().add(const Duration(days: 6));
                      startDateController.text = getOnlyDate(startDate) +
                          ' ' +
                          TimeOfDay.now().format(context);
                      endDateController.text =
                          getOnlyDate(endDate) + ' 11:59 PM';
                    });
                  }),
              Text(
                '7 ${_trans.days}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 20,
              ),
              Radio(
                  visualDensity: const VisualDensity(horizontal: -4),
                  value: 4,
                  groupValue: selectedDaysRadio,
                  onChanged: (value) {
                    setState(() {
                      selectedDaysRadio = 4;
                      dateFieldsHidden = false;
                      startDate = DateTime.now();
                      endDate = DateTime.now();
                      startDateController.text = getOnlyDate(startDate) +
                          ' ' +
                          TimeOfDay.now().format(context);
                      endDateController.text =
                          getOnlyDate(endDate) + ' 11:59 PM';
                      startTime = TimeOfDay.now();
                      endTime = const TimeOfDay(hour: 11, minute: 59);
                    });
                  }),
              Text(
                _trans.indefinite,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (!dateFieldsHidden)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_trans.start_date)),
                SizedBox(
                  width: 185,
                  child: DropDownTextField(
                    hintText: _trans.start_date,
                    controller: startDateController,
                    handleTap: () async {
                      var date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day + 15));
                      if (date != null) {
                        if (date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day) {
                          startDateController.text = getOnlyDate(date) +
                              ' ' +
                              TimeOfDay.now().format(context);
                        } else {
                          startDateController.text =
                              getOnlyDate(date) + ' 12 AM';
                        }
                        startDate = date;
                      }
                    },
                  ),
                ),
              ],
            ),
          if (!dateFieldsHidden)
            const SizedBox(
              height: 10,
            ),
          if (!dateFieldsHidden)
            Row(
              children: [
                Expanded(child: Text(_trans.end_date)),
                SizedBox(
                  width: 185,
                  child: DropDownTextField(
                    hintText: _trans.end_date,
                    controller: endDateController,
                    handleTap: () async {
                      var date = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: startDate,
                          lastDate: DateTime(startDate.year, startDate.month,
                              startDate.day + 15));
                      if (date != null) {
                        /* var time = await showTimePicker(
                            context: context, initialTime: startTime); */
                        //if (time != null) {
                        endDateController.text =
                            getOnlyDate(date) + ' 11:59 PM';
                        endDate = date;
                        // endTime = time;
                        //}
                      }
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 30,
          ),
          Text(
            _trans.are_you_sure_you_want_to_change_item_availability,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      actions: <Widget>[
        TextButton(
          child: Text(
            _trans.no,
            style: TextStyle(color: MyColors.green),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            _trans.yes,
            style: TextStyle(color: MyColors.green),
          ),
          onPressed: () {
            if (dateFieldsHidden) {
              Provider.of<InventoryViewModel>(context, listen: false)
                  .changeInventoryItemAvailability(
                itemId: widget.itemId,
                kitchenId: widget.kitchenId,
                newAvailability: widget.newStatus,
                startDate: startDateController.text,
                endDate: endDateController.text,
              );
              Navigator.of(context).pop();
            } else {
              if ((endDate.year >= startDate.year &&
                      endDate.month <= startDate.month) &&
                  (endDate.day >= startDate.day ||
                      (endDate.day < startDate.day &&
                          endDate.month > startDate.month))) {
                Provider.of<InventoryViewModel>(context, listen: false)
                    .changeInventoryItemAvailability(
                  itemId: widget.itemId,
                  kitchenId: widget.kitchenId,
                  newAvailability: widget.newStatus,
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                );
                Navigator.of(context).pop();
              } else {
                showToast(message: _trans.select_valid_dates);
              }
            }
          },
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/colors.dart';
import '../../../../common/prefs_keys.dart';
import '../../../../infrastructure/home/model/print_receipt.dart';
import '../../../../util/global_functions.dart';
import '../../../../util/printing_service.dart';
import '../../../../viewModels/settings_view_model.dart';
import '../../../customWidgets/loading_icon_widget.dart';

class PrintDialog extends StatefulWidget {
  const PrintDialog({
    Key? key,
    required this.receipt,
    required this.printQR,
    required this.printImage,
  }) : super(key: key);

  final PrintReceipt receipt;
  final bool printQR;
  final bool printImage;

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  List? _devices = [];
  String? _device;
  bool _connected = false;
  bool _loading = false;
  late AppLocalizations? _trans;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected =
        await BluetoothThermalPrinter.connectionStatus == 'true';
    List? devices = [];
    try {
      devices = await BluetoothThermalPrinter.getBluetooths;
    } on PlatformException catch (e) {
      showToast(message: e.toString());
    }

    /* bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    }); */

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> _connect() async {
    if (_device == null) {
    } else {
      await BluetoothThermalPrinter.connectionStatus.then((isConnected) async {
        if (isConnected! != 'true') {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
              PrefsKeys.bluetoothDevice, json.encode(_device!));
          await BluetoothThermalPrinter.connect(_device!).catchError((error) {
            _connected = false;
            sharedPreferences.remove(
              PrefsKeys.bluetoothDevice,
            );
            showToast(message: _trans!.connecting_to_printer_error);
          });

          _connected = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _trans = AppLocalizations.of(context);
    bool isDark = Provider.of<SettingsViewModel>(context, listen: false)
            .setting
            .brightness ==
        Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: isDark ? MyColors.backgroundLevel0 : MyColors.white,
      child: _loading
          ? const SizedBox(height: 459, child: LoadingIconWidget())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  _trans!.please_choose_printer,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: isDark ? MyColors.white : MyColors.black,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 400,
                  child: _devices!.isNotEmpty
                      ? ListView.builder(
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () async {
                              String select = _devices![i];
                              List list = select.split("#");
                              _device = list[1];
                              setState(() {
                                _loading = true;
                              });
                              await _connect();
                              if (_connected) {
                                PrintingService.printToPosPrinter(
                                  popWidget: true,
                                  receipt: widget.receipt,
                                  printQR: widget.printQR,
                                  printImage: widget.printImage,
                                );
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                                showToast(
                                    message:
                                        _trans!.connecting_to_printer_error);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(_devices![i],
                                        style: const TextStyle(
                                          fontSize: 15,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          itemCount: _devices!.length,
                          shrinkWrap: true,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(_trans!.none,
                              style: const TextStyle(
                                fontSize: 15,
                              )),
                        ),
                ),
              ],
            ),
    );
  }
}

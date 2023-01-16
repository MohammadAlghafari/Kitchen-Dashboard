import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_star_prnt/flutter_star_prnt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/printer_code_pages.dart';
import '../infrastructure/home/model/print_receipt.dart';
import '../common/prefs_keys.dart';
import '../viewModels/settings_view_model.dart';
import 'navigation_service.dart';
import 'global_functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../view/screens/home/widgets/print_dialog.dart';

class PrintingService {
  //check for bluetooth permissions
  static checkPermission() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }

  // get the emulation for the star printer model
  static String emulationFor(String? modelName) {
    String? emulation = 'StarGraphic';
    if (modelName != null && modelName != '') {
      final em = StarMicronicsUtilities.detectEmulation(modelName: modelName);
      emulation = em?.emulation;
    }
    return emulation!;
  }

  //connect to esc/pos bluetooth printer
  static Future<bool> _connect() async {
    bool? bluetoothConnected =
        await BluetoothThermalPrinter.connectionStatus == 'true';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (bluetoothConnected) {
      String _device =
          sharedPreferences.getString(PrefsKeys.bluetoothDevice).toString();
      await BluetoothThermalPrinter.connectionStatus.then((isConnected) async {
        if (isConnected! != 'true') {
          await BluetoothThermalPrinter.connect(_device).catchError((error) {
            sharedPreferences.remove(PrefsKeys.bluetoothDevice);
            showToast(message: error.toString());
          });
          return true;
        }
      });
      return true;
    } else {
      sharedPreferences.remove(PrefsKeys.bluetoothDevice);
      showToast(
          message: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .please_try_again);
      return false;
    }
  }

  static Future<void> printReceipt(
      {required PrintReceipt receipt,
      required bool printQR,
      required bool printImage}) async {
    //check if it's web or not bluetooth connected printer print pdf

    if (kIsWeb ||
        !receipt.connectionType!.toLowerCase().contains('bluetooth')) {
      await printFromWeb(
          receipt.resultData, receipt.language!, receipt.pdfType!);
    } else {
      FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
      bool bluetoothOn = await flutterBlue.isOn;
      if (bluetoothOn) {
        //if printer type is star print to star printer using star commands
        //else printer is fiscal device print to fiscal
        //else print to esc/pos printer using pos commands
        await checkPermission();
        if (receipt.printerType!.toLowerCase().contains('star')) {
          // print("print from star");

          await printToStarPrinter(receipt: receipt, printQR: printQR);
        } else {
          if (receipt.printerType!.toLowerCase().contains('fiscal')) {
            // print("print from fiscal");
            launchPrintToFiskoService(receipt.resultData!);
          } else {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            //if the printer is not connected or not store in sharedPreferences
            //show select printer dialog to connect else print directly
            if (sharedPreferences.containsKey(PrefsKeys.bluetoothDevice) &&
                sharedPreferences.getString(PrefsKeys.bluetoothDevice) !=
                    null) {
              // print("print from preferences");
              if (await _connect()) {
                await printToPosPrinter(
                    popWidget: false,
                    printQR: printQR,
                    printImage: printImage,
                    receipt: receipt);
              }
            } else {
              // print("print from else");
              showDialog(
                  context: NavigationService.navigatorKey.currentContext!,
                  builder: (context) => PrintDialog(
                        receipt: receipt,
                        printQR: printQR,
                        printImage: printImage,
                      ));
            }
          }
        }
      } else {
        showToast(
            message: AppLocalizations.of(
                    NavigationService.navigatorKey.currentContext!)!
                .please_turn_bluetooth_on);
      }
    }
  }

  static printFromWeb(customerData, String language, String pdfType) async {

     var ttfBold = await PdfGoogleFonts.iBMPlexSansArabicBold();
    final ttfNormal = await PdfGoogleFonts.iBMPlexSansArabicMedium();
    if(language == "english"){
      ttfBold = await  PdfGoogleFonts.iBMPlexSerifBold();
    }else{
       ttfBold = await PdfGoogleFonts.iBMPlexSansArabicBold();
    }
    final pdfDocument = pw.Document();
    if (pdfType == "kitchen") {
      const double fontSize = 10.00;
      pdfDocument.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
              80 * PdfPageFormat.mm, MediaQuery.of(NavigationService.navigatorKey.currentState!.context).size.height),
          textDirection: language == "english"
              ? pw.TextDirection.ltr
              : pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 10),
              child: pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 4.00),
                child: language == "english"
                    ? pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text("Order ID",
                                    style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                    ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(customerData["order_id"].toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                    ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text("Pickup By",
                                    style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["pickup_by"].toString(),
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text("Customer Name",
                                    style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["customer_name"].toString(),
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text("Order Date",
                                    style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["order_date"].toString(),
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  "Order At",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["order_at"].toString(),
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  "Prepare By",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["prepare_by"].toString(),
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.05,
                              ),
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 80,
                                  child: pw.Text(
                                    "Comments",
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfBold,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 10,
                                  child: pw.Text(
                                    ":",
                                    style: const pw.TextStyle(
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    customerData["comments"] ?? "",
                                    textDirection: pw.TextDirection.ltr,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "Item Name",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                child: pw.Text(
                                  "Quantity",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Container(
                            width: double.infinity,
                            child: pw.ListView.builder(
                              itemCount: customerData["items"].length,
                              itemBuilder: (context, index) {
                                return pw.Column(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(3),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 0.05,
                                        ),
                                      ),
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Container(
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.SizedBox(
                                                  width: 180,
                                                  child:
                                                pw.Text(
                                                  customerData["items"][index]
                                                          ["item_name"]
                                                      .toString()
                                                      .trim(),
                                                  maxLines: 3,
                                                  textAlign: pw.TextAlign.left,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                                ),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.SizedBox(height: 5),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.Text(
                                                    "Add Ons:",
                                                    maxLines: 3,
                                                    textAlign:
                                                        pw.TextAlign.left,
                                                    style: pw.TextStyle(
                                                      fontSize: fontSize,
                                                      font: ttfNormal,
                                                    ),
                                                  ),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.Container(
                                                    width: 180.0,
                                                    alignment:
                                                        pw.Alignment.centerLeft,
                                                    child: pw.ListView.builder(
                                                      itemCount:
                                                          customerData["items"]
                                                                      [index]
                                                                  ["addons"]
                                                              .keys
                                                              .length,
                                                      itemBuilder:
                                                          (context, ind) {
                                                        return pw.Column(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            pw.Text(
                                                              customerData["items"]
                                                                          [
                                                                          index]
                                                                      ["addons"]
                                                                  .keys
                                                                  .elementAt(
                                                                      ind)
                                                                  .toString()
                                                                  .trim(),
                                                              maxLines: 3,
                                                              textAlign: pw
                                                                  .TextAlign
                                                                  .left,
                                                              style: pw.TextStyle(
                                                                  fontSize:
                                                                      fontSize,
                                                                  font: ttfBold,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold),
                                                            ),
                                                            pw.Container(
                                                              width: 80,
                                                              alignment: pw
                                                                  .Alignment
                                                                  .centerLeft,
                                                              child: pw.ListView
                                                                  .builder(
                                                                itemCount: customerData["items"]
                                                                            [
                                                                            index]
                                                                        [
                                                                        "addons"]
                                                                    .values
                                                                    .elementAt(
                                                                        ind)
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        innerIndex) {
                                                                  return pw
                                                                      .Container(
                                                                    width: 80,
                                                                    alignment: pw
                                                                        .Alignment
                                                                        .centerLeft,
                                                                    child:
                                                                        pw.Text(
                                                                      "${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["name"].toString().trim()}"
                                                                      " x${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["quantity"].toString().trim()}",
                                                                      maxLines:
                                                                          3,
                                                                      style: pw
                                                                          .TextStyle(
                                                                        fontSize:
                                                                            fontSize,
                                                                        font:
                                                                            ttfNormal,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          pw.Container(
                                            width: 70,
                                            child: pw.Text(
                                              customerData["items"][index]
                                                      ["quantity"]
                                                  .toString(),
                                              style: pw.TextStyle(
                                                fontSize: fontSize,
                                                font: ttfBold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.SizedBox(height: 3),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["order_id"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "معرف الطلب\n Order ID",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["pickup_by"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "طريقة الاستلام\n Pickup By",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["customer_name"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "اسم الزبون\n Customer Name",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["order_date"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "تاريخ الطلب\n Order Date",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["order_at"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "اطلب في\n Order At",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  customerData["prepare_by"],
                                  maxLines: 3,
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfNormal,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 10,
                                child: pw.Text(
                                  ":",
                                  style: const pw.TextStyle(
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  "الاستعداد بواسطة\n Prepare By",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.05,
                              ),
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    customerData["comments"] ?? "No Comments",
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 10,
                                  child: pw.Text(
                                    ":",
                                    style: const pw.TextStyle(
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 80,
                                  child: pw.Text(
                                    "تعليقات\n Comments",
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfBold,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                child: pw.Text(
                                  "الكمية\n Quantity",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                child: pw.Text(
                                  "اسم المنتج\n Item Name",
                                  style: pw.TextStyle(
                                    fontSize: fontSize,
                                    font: ttfBold,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 3,
                          ),
                          pw.Container(
                            width: double.infinity,
                            child: pw.ListView.builder(
                              itemCount: customerData["items"].length,
                              itemBuilder: (context, index) {
                                return pw.Column(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(3),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 0.05,
                                        ),
                                      ),
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Container(
                                            child: pw.Text(
                                              customerData["items"][index]
                                                      ["quantity"]
                                                  .toString(),
                                              style: pw.TextStyle(
                                                fontSize: fontSize,
                                                font: ttfBold,
                                              ),
                                            ),
                                          ),
                                          pw.Container(
                                            width: 180,
                                            alignment: pw.Alignment.centerRight,
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.end,
                                              children: [
                                                pw.Text(
                                                  customerData["items"][index]
                                                          ["item_name"]
                                                      .toString()
                                                      // .replaceAll("(", ")").replaceAll(")", "("),
                                                      .trim(),
                                                  maxLines: 3,
                                                  textAlign: pw.TextAlign.right,
                                                  textDirection: pw.TextDirection.rtl,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.SizedBox(height: 5),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.Text(
                                                    "إضافات\n Add Ons",
                                                    maxLines: 3,
                                                    textAlign:
                                                        pw.TextAlign.right,
                                                    style: pw.TextStyle(
                                                      fontSize: fontSize,
                                                      font: ttfNormal,
                                                    ),
                                                  ),
                                                if (customerData["items"][index]
                                                            ["addons"]
                                                        .length >=
                                                    1)
                                                  pw.Container(
                                                    width: 180,
                                                    alignment:
                                                        pw.Alignment.centerLeft,
                                                    child: pw.ListView.builder(
                                                      itemCount:
                                                          customerData["items"]
                                                                      [index]
                                                                  ["addons"]
                                                              .keys
                                                              .length,
                                                      itemBuilder:
                                                          (context, ind) {
                                                        return pw.Column(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .end,
                                                          children: [
                                                            pw.Text(
                                                              customerData["items"]
                                                                          [
                                                                          index]
                                                                      ["addons"]
                                                                  .keys
                                                                  .elementAt(
                                                                      ind)
                                                                  .toString()
                                                                  .trim(),
                                                              maxLines: 3,
                                                              textAlign: pw
                                                                  .TextAlign
                                                                  .right,
                                                              style:
                                                                  pw.TextStyle(
                                                                fontSize:
                                                                    fontSize,
                                                                font: ttfBold,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                            pw.Container(
                                                              width: 180,
                                                              alignment: pw
                                                                  .Alignment
                                                                  .centerLeft,
                                                              child: pw.ListView
                                                                  .builder(
                                                                itemCount: customerData["items"]
                                                                            [
                                                                            index]
                                                                        [
                                                                        "addons"]
                                                                    .values
                                                                    .elementAt(
                                                                        ind)
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        innerIndex) {
                                                                  return pw
                                                                      .Container(
                                                                    width: 180,
                                                                    alignment: pw
                                                                        .Alignment
                                                                        .centerRight,
                                                                    child:
                                                                        pw.Text(
                                                                          Provider.of<SettingsViewModel>(NavigationService.navigatorKey.currentState!.context, listen: false)
                                                                              .setting
                                                                              .mobileLanguage
                                                                              .languageCode ==
                                                                              'ar'?
                                                                          "x${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["quantity"].toString().trim()}" " ${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["name"].toString().trim()}":
                                                                          "${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["name"].toString().trim()}"" x${customerData["items"][index]["addons"].values.elementAt(ind)[innerIndex]["quantity"].toString().trim()}" ,
                                                                      maxLines:
                                                                          3,
                                                                      textAlign: pw
                                                                          .TextAlign
                                                                          .right,
                                                                      textDirection:
                                                                      Provider.of<SettingsViewModel>(NavigationService.navigatorKey.currentState!.context, listen: false)
                                                                          .setting
                                                                          .mobileLanguage
                                                                          .languageCode ==
                                                                          'ar'
                                                                          ? pw.TextDirection.rtl
                                                                          : pw.TextDirection.ltr,
                                                                      style: pw
                                                                          .TextStyle(
                                                                        fontSize:
                                                                            fontSize,
                                                                        font:
                                                                            ttfNormal,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.SizedBox(height: 3),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      );
      Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfDocument.save());
    }
    else if (pdfType == "customer_belgium") {
      const double fontSize = 9.00;
      pdfDocument.addPage(pw.Page(
          pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, MediaQuery.of(NavigationService.navigatorKey.currentState!.context).size.height),
          textDirection: pw.TextDirection.ltr,
          build: (pw.Context context) {
            return
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 0.00, vertical: 10),
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["order_id"]["name_en"].toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["order_id"]["value_en"].toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["brand_name"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["brand_name"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["delivered_by"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["delivered_by"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["order_date"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["order_date"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["order_time"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["order_time"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["customer_name"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["customer_name"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["customer_phone"]["name_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                customerData["customer_phone"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 200,
                        padding:
                            const pw.EdgeInsets.symmetric(horizontal: 3.00),
                        // margin: const pw.EdgeInsets.only(left: 3.00, right: 3.00),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 1.0,
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 90,
                                  child: pw.Text(
                                    "Name",
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 30,
                                  child: pw.Text(
                                    "Qty",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 50,
                                  child: pw.Text(
                                    "Amount Inc VAT ${customerData["vat_p"]["value_en"]}",
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.Divider(),
                            pw.ListView.builder(
                              itemCount: customerData["ordered_items"]["data"]
                                  .keys
                                  .length,
                              itemBuilder: (context, index) {
                                return pw.Column(
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Container(
                                          width: 100,
                                          child: pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                "${customerData["ordered_items"]["data"]["item$index"]["item_name_en"]}",
                                                textAlign: pw.TextAlign.left,
                                                maxLines: 4,
                                                textDirection:
                                                    pw.TextDirection.ltr,
                                                style: pw.TextStyle(
                                                  fontSize: fontSize,
                                                  font: ttfBold,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                ),
                                              ),
                                              if (customerData["ordered_items"]
                                                                  ["data"]
                                                              ["item$index"]
                                                          ["addons"]
                                                      .length >
                                                  0)
                                                pw.ListView.builder(
                                                  itemCount:
                                                      customerData["ordered_items"]
                                                                      ["data"]
                                                                  ["item$index"]
                                                              ["addons"]
                                                          .length,
                                                  itemBuilder: (context, ind) {
                                                    return pw.Column(
                                                      crossAxisAlignment: pw
                                                          .CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        pw.Row(
                                                          mainAxisAlignment: pw
                                                              .MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            pw.Container(
                                                              // width: 90,
                                                              child: pw.Row(
                                                                crossAxisAlignment:
                                                                    pw.CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  pw.Container(
                                                                    width: 90,
                                                                    child:
                                                                        pw.Row(
                                                                      children: [
                                                                        pw.Text(
                                                                          "*${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_name_en"]} x${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_qty"]}",
                                                                          textAlign: pw
                                                                              .TextAlign
                                                                              .left,
                                                                          maxLines:
                                                                              4,
                                                                          textDirection: pw
                                                                              .TextDirection
                                                                              .rtl,
                                                                          style:
                                                                              pw.TextStyle(
                                                                            fontSize:
                                                                                fontSize,
                                                                            font:
                                                                                ttfNormal,
                                                                            fontWeight:
                                                                                pw.FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        pw.SizedBox(
                                                          height: 3,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                        pw.Container(
                                          width: 30,
                                          child: pw.Text(
                                            customerData["ordered_items"]
                                                        ["data"]["item$index"]
                                                    ["quantity"]
                                                .toString(),
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              fontSize: fontSize,
                                              font: ttfBold,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        pw.Container(
                                          width: 30,
                                          child: pw.Text(
                                            customerData["ordered_items"]
                                                        ["data"]["item$index"]
                                                    ["amount_with_vat"]
                                                .toString(),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              fontSize: fontSize,
                                              font: ttfBold,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (customerData["ordered_items"]["data"]
                                            .keys
                                            .length !=
                                        index + 1)
                                      pw.Divider(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["total_items"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["total_items"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["total_amount"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["total_amount"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["discount"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["discount"]["value_en"].toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["total_amt_after_discount"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["total_amt_after_discount"]
                                        ["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["delivery_fee"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["delivery_fee"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["amount_with_vat"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["amount_with_vat"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["vat"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["vat"]["value_en"].toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["amount_only"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["amount_only"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5.00),
                      pw.Container(
                        width: 180,
                        alignment: pw.Alignment.center,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text(
                                "${customerData["collectible"]["name_en"]}",
                                textAlign: pw.TextAlign.left,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              ":",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfNormal,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 60,
                              child: pw.Text(
                                customerData["collectible"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfNormal,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }));
      Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfDocument.save());

      ///request the pdf file from server to print from web
      // final pdfFileResponse = await http.post(Uri.parse(Urls.baseUrl + Urls.pdf),
      //     headers: {
      //       'Access-Control-Allow-Origin': '*',
      //       'Content-Type': 'application/json',
      //       'Accept': 'application/json',
      //     },
      //     body: json.encode({'file_name': pdfUrl}));
      // final pdfData = pdfFileResponse.bodyBytes;
      // try {
      //   Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
      // } catch (e) {
      //   showToast(message: e.toString());
      // }

    }
    else {
      const double fontSize = 9.00;
      pdfDocument.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, MediaQuery.of(NavigationService.navigatorKey.currentState!.context).size.height),
          textDirection: language == "english"
              ? pw.TextDirection.ltr
              : pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 0.00,
                  vertical: 10,
                ),
                child: pw.Container(
                  // width: 200,
                  alignment: pw.Alignment.center,
                  child: language != "english"
                      ? pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              "${customerData["invoice_header"]["value_ar"]}  ${customerData["invoice_header"]["value_en"]} / ",
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              "${customerData["company_name"]["name_ar"]}",
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            customerData["invoice_address"]["value_ar"]
                                .toString().contains("-")?
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                            pw.Text(
                                customerData["invoice_address"]["value_ar"]
                                    .toString().split("-")[1] + " - ",
                              textDirection: pw.TextDirection.rtl,
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                              pw.Text(
                                customerData["invoice_address"]["value_ar"]
                                    .toString().split("-")[0],
                              textDirection: pw.TextDirection.rtl,
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            ],
                            ):
                            pw.Text(
                              customerData["invoice_address"]["value_ar"]
                                  .toString(),
                              textDirection: pw.TextDirection.rtl,
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 180.0,
                              child: pw.Text(
                                "${customerData["invoice_address"]["value_en"]}",
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 110,
                                    child: pw.Text(
                                      customerData["tax_number"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    child: pw.Text(
                                      customerData["tax_number"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["invoice_number"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    child: pw.Text(
                                      customerData["invoice_number"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["contact_info"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    child: pw.Text(
                                      customerData["contact_info"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Divider(),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_id"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_id"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["brand_name"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["brand_name"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["delivered_by"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["delivered_by"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_date"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_date"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_time"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_time"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["customer_name"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["customer_name"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["customer_phone"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["customer_phone"]["name_ar"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 200,
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 3.00,
                              ),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Container(
                                        width: 30,
                                        child: pw.Text(
                                          "${customerData["ordered_items"]["title"]["item2"]["value"]}\n ${customerData["vat_p"]["value_en"]}",
                                          textAlign: pw.TextAlign.left,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Container(
                                        width: 30,
                                        child: pw.Text(
                                          customerData["ordered_items"]["title"]
                                                  ["item1"]["value"]
                                              .toString(),
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Container(
                                        width: 130,
                                        child: pw.Text(
                                          customerData["ordered_items"]["title"]
                                                  ["item0"]["value"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.Divider(),
                                  pw.ListView.builder(
                                    itemCount: customerData["ordered_items"]
                                            ["data"]
                                        .keys
                                        .length,
                                    itemBuilder: (context, index) {
                                      return pw.Column(
                                        children: [
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Container(
                                                width: 30,
                                                child: pw.Text(
                                                  customerData["ordered_items"]
                                                                  ["data"]
                                                              ["item$index"]
                                                          ["amount_with_vat"]
                                                      .toString(),
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              pw.Container(
                                                width: 30,
                                                child: pw.Text(
                                                  // "hey",
                                                  customerData["ordered_items"]
                                                                  ["data"]
                                                              ["item$index"]
                                                          ["quantity"]
                                                      .toString(),
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              pw.Container(
                                                width: 130,
                                                child: pw.Column(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment.end,
                                                    children: [
                                                      pw.Text(
                                                        "${customerData["ordered_items"]["data"]["item$index"]["item_name_ar"]}",
                                                        maxLines: 4,
                                                        textAlign:
                                                            pw.TextAlign.left,
                                                        textDirection: pw
                                                            .TextDirection.rtl,
                                                        style: pw.TextStyle(
                                                          fontSize: fontSize,
                                                          font: ttfBold,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                        ),
                                                      ),
                                                      pw.Text(
                                                        "${customerData["ordered_items"]["data"]["item$index"]["item_name_en"]}",
                                                        textAlign:
                                                            pw.TextAlign.right,
                                                        maxLines: 4,
                                                        textDirection: pw
                                                            .TextDirection.ltr,
                                                        style: pw.TextStyle(
                                                          fontSize: fontSize,
                                                          font: ttfBold,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (customerData["ordered_items"]
                                                                          [
                                                                          "data"]
                                                                      [
                                                                      "item$index"]
                                                                  ["addons"]
                                                              .length >
                                                          0)
                                                        pw.ListView.builder(
                                                          itemCount: customerData[
                                                                              "ordered_items"]
                                                                          [
                                                                          "data"]
                                                                      [
                                                                      "item$index"]
                                                                  ["addons"]
                                                              .length,
                                                          itemBuilder:
                                                              (context, ind) {
                                                            return pw.Column(
                                                              crossAxisAlignment:
                                                                  pw.CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                pw.Row(
                                                                  mainAxisAlignment: pw
                                                                      .MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    pw.Container(
                                                                      child: pw
                                                                          .Row(
                                                                        crossAxisAlignment: pw
                                                                            .CrossAxisAlignment
                                                                            .end,
                                                                        children: [
                                                                          pw.Container(
                                                                            width:
                                                                                90,
                                                                            child:
                                                                                pw.Row(
                                                                              children: [
                                                                                pw.Column(
                                                                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                                                  children: [
                                                                                    pw.Container(
                                                                                      width: 100,
                                                                                      child:
                                                                                    pw.Text(
                                                                                      customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_name_ar"].toString().isNotEmpty ? "*${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_name_ar"]} x${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_qty"]}" : "",
                                                                                      textAlign: pw.TextAlign.left,
                                                                                      maxLines: 4,
                                                                                      textDirection: pw.TextDirection.ltr,
                                                                                      style: pw.TextStyle(
                                                                                        fontSize: fontSize,
                                                                                        font: ttfNormal,
                                                                                        fontWeight: pw.FontWeight.normal,
                                                                                      ),
                                                                                    ),
                                                                                    ),
                                                                                    pw.Container(
                                                                                      width: 130,
                                                                                      child:
                                                                                      pw.Text(
                                                                                      "${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_name_en"]} x${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_qty"]}",
                                                                                      textAlign: pw.TextAlign.right,
                                                                                      maxLines: 4,
                                                                                      textDirection: pw.TextDirection.ltr,
                                                                                      style: pw.TextStyle(
                                                                                        fontSize: fontSize,
                                                                                        font: ttfNormal,
                                                                                        fontWeight: pw.FontWeight.normal,
                                                                                      ),
                                                                                    ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                pw.SizedBox(
                                                                  height: 3,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                    ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (customerData["ordered_items"]
                                                      ["data"]
                                                  .keys
                                                  .length !=
                                              index + 1)
                                            pw.Divider(),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_items"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["total_items"]["name_en"]}",
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["total_items"]["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_amount"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["total_amount"]["name_en"]}",
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["total_amount"]
                                                  ["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["discount"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["discount"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["discount"]["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_amt_after_discount"]
                                              ["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["total_amt_after_discount"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData[
                                                      "total_amt_after_discount"]
                                                  ["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["delivery_fee"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["delivery_fee"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["delivery_fee"]
                                                  ["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["amount_with_vat"]
                                              ["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["amount_with_vat"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["amount_with_vat"]
                                                  ["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["vat"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["vat"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["vat"]["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["amount_only"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          "${customerData["amount_only"]["name_en"]}",
                                          textAlign: pw.TextAlign.right,
                                          textDirection: pw.TextDirection.ltr,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          customerData["amount_only"]["name_ar"]
                                              .toString(),
                                          textAlign: pw.TextAlign.left,
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfBold,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["collectible"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            "${customerData["collectible"]["name_en"]}",
                                            textAlign: pw.TextAlign.right,
                                            textDirection: pw.TextDirection.ltr,
                                            style: pw.TextStyle(
                                              fontSize: fontSize,
                                              font: ttfBold,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.Text(
                                            customerData["collectible"]
                                                    ["name_ar"]
                                                .toString(),
                                            textAlign: pw.TextAlign.left,
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: fontSize,
                                              font: ttfBold,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 30.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "${customerData["footer"]["value_ar"]}",
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "${customerData["footer"]["value_en"]}",
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20.00),
                            customerData["qr_code"]["value_en"]
                                    .toString()
                                    .isNotEmpty
                                ? pw.BarcodeWidget(
                                    height: 100,
                                    width: 100,
                                    color: PdfColor.fromHex("#000000"),
                                    barcode: pw.Barcode.qrCode(),
                                    data:
                                        "${customerData["qr_code"]["value_en"]}")
                                : pw.Container()
                          ],
                        )
                      : pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              "${customerData["invoice_header"]["value_en"]}",
                              style: pw.TextStyle(
                                fontSize: fontSize,
                                font: ttfBold,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              width: 180.0,
                              child: pw.Text(
                                customerData["invoice_address"]["value_en"]
                                    .toString(),
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Container(
                                      // width: 60,
                                      child: pw.Text(
                                        customerData["tax_number"]["name_en"]
                                            .toString(),
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: fontSize,
                                          font: ttfNormal,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                      width: 110,
                                      child: pw.Text(
                                        customerData["tax_number"]["value_en"]
                                            .toString(),
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          fontSize: fontSize,
                                          font: ttfNormal,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    // width: 70,
                                    child: pw.Text(
                                      customerData["invoice_number"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 110,
                                    child: pw.Text(
                                      customerData["invoice_number"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    // width: 70,
                                    child: pw.Text(
                                      customerData["contact_info"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["contact_info"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Divider(),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_id"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_id"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["brand_name"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["brand_name"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["delivered_by"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["delivered_by"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_date"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_date"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["order_time"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["order_time"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["customer_name"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["customer_name"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["customer_phone"]["name_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      customerData["customer_phone"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 200,
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 3.00),
                              // margin: const pw.EdgeInsets.only(left: 3.00, right: 3.00),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Container(
                                        width: 90,
                                        child: pw.Text(
                                          "Name",
                                          textAlign: pw.TextAlign.left,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Container(
                                        width: 30,
                                        child: pw.Text(
                                          "Qty",
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Container(
                                        width: 50,
                                        child: pw.Text(
                                          "Amount Inc VAT ${customerData["vat_p"]["value_en"]}",
                                          textAlign: pw.TextAlign.left,
                                          style: pw.TextStyle(
                                            fontSize: fontSize,
                                            font: ttfNormal,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.Divider(),
                                  pw.ListView.builder(
                                    itemCount: customerData["ordered_items"]
                                            ["data"]
                                        .keys
                                        .length,
                                    itemBuilder: (context, index) {
                                      return pw.Column(
                                        children: [
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Container(
                                                width: 100,
                                                child: pw.Column(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      pw.Text(
                                                        "${customerData["ordered_items"]["data"]["item$index"]["item_name_en"]}",
                                                        textAlign:
                                                            pw.TextAlign.left,
                                                        maxLines: 4,
                                                        textDirection: pw
                                                            .TextDirection.ltr,
                                                        style: pw.TextStyle(
                                                          fontSize: fontSize,
                                                          font: ttfBold,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (customerData["ordered_items"]
                                                                          [
                                                                          "data"]
                                                                      [
                                                                      "item$index"]
                                                                  ["addons"]
                                                              .length >
                                                          0)
                                                        pw.ListView.builder(
                                                          itemCount: customerData[
                                                                              "ordered_items"]
                                                                          [
                                                                          "data"]
                                                                      [
                                                                      "item$index"]
                                                                  ["addons"]
                                                              .length,
                                                          itemBuilder:
                                                              (context, ind) {
                                                            return pw.Column(
                                                              crossAxisAlignment:
                                                                  pw.CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                pw.Row(
                                                                  mainAxisAlignment: pw
                                                                      .MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    pw.Container(
                                                                      child: pw.Row(
                                                                          crossAxisAlignment: pw
                                                                              .CrossAxisAlignment
                                                                              .end,
                                                                          children: [
                                                                            pw.Container(
                                                                              width: 90,
                                                                              child: pw.Row(children: [
                                                                                pw.Text(
                                                                                  "*${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_name_en"]} x${customerData["ordered_items"]["data"]["item$index"]["addons"]["addon$ind"]["addon_qty"]}",
                                                                                  textAlign: pw.TextAlign.left,
                                                                                  maxLines: 4,
                                                                                  textDirection: pw.TextDirection.rtl,
                                                                                  style: pw.TextStyle(
                                                                                    fontSize: fontSize,
                                                                                    font: ttfNormal,
                                                                                    fontWeight: pw.FontWeight.normal,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                  ],
                                                                ),
                                                                pw.SizedBox(
                                                                  height: 3,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        )
                                                    ]),
                                              ),
                                              pw.Container(
                                                width: 30,
                                                child: pw.Text(
                                                  customerData["ordered_items"]
                                                                  ["data"]
                                                              ["item$index"]
                                                          ["quantity"]
                                                      .toString(),
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              pw.Container(
                                                width: 30,
                                                child: pw.Text(
                                                  customerData["ordered_items"]
                                                                  ["data"]
                                                              ["item$index"]
                                                          ["amount_with_vat"]
                                                      .toString(),
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                    fontSize: fontSize,
                                                    font: ttfBold,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (customerData["ordered_items"]
                                                      ["data"]
                                                  .keys
                                                  .length !=
                                              index + 1)
                                            pw.Divider(),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["total_items"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_items"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["total_amount"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_amount"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["discount"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["discount"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["total_amt_after_discount"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["total_amt_after_discount"]
                                              ["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["delivery_fee"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["delivery_fee"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["amount_with_vat"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["amount_with_vat"]
                                              ["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["vat"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["vat"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["amount_only"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["amount_only"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 5.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 120,
                                    child: pw.Text(
                                      "${customerData["collectible"]["name_en"]}",
                                      textAlign: pw.TextAlign.left,
                                      textDirection: pw.TextDirection.ltr,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfBold,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    ":",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      font: ttfNormal,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text(
                                      customerData["collectible"]["value_en"]
                                          .toString(),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: fontSize,
                                        font: ttfNormal,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 30.00),
                            pw.Container(
                              width: 180,
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "${customerData["footer"]["value_en"]}",
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.ltr,
                                style: pw.TextStyle(
                                  fontSize: fontSize,
                                  font: ttfBold,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20.00),
                            customerData["qr_code"]["value_en"]
                                    .toString()
                                    .isNotEmpty
                                ? pw.BarcodeWidget(
                                    height: 100,
                                    width: 100,
                                    color: PdfColor.fromHex("#000000"),
                                    barcode: pw.Barcode.qrCode(),
                                    data:
                                        "${customerData["qr_code"]["value_en"]}",
                                  )
                                : pw.Container()
                          ],
                        ),
                ),
              )
            ];
          },
        ),
      );
      Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfDocument.save());

      ///request the pdf file from server to print from web
      // final pdfFileResponse = await http.post(Uri.parse(Urls.baseUrl + Urls.pdf),
      //     headers: {
      //       'Access-Control-Allow-Origin': '*',
      //       'Content-Type': 'application/json',
      //       'Accept': 'application/json',
      //     },
      //     body: json.encode({'file_name': pdfUrl}));
      // final pdfData = pdfFileResponse.bodyBytes;
      // try {
      //   Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
      // } catch (e) {
      //   showToast(message: e.toString());
      // }
    }
  }

  static Future<void> printToStarPrinter(
      {required PrintReceipt receipt, required bool printQR}) async {
    try {
      //discover the star printer and connect to it for print
      List<PortInfo> list = await StarPrnt.portDiscovery(StarPortType.All);
      for (var port in list) {
        if (port.portName!.isNotEmpty) {
          /* print(await StarPrnt.getStatus(
          portName: port.portName!,
          emulation: emulationFor(port.modelName!),
        )); */
          PrintCommands commands = PrintCommands();
          commands.appendBitmapText(text: receipt.resultData!);
          if (printQR &&
              receipt.qrUrl!.trim().isNotEmpty &&
              receipt.qrUrl! != '') {
            commands.appendBitmapByte(
              byteData: await generateQrImage(receipt.qrUrl!),
              width: 175,
              alignment: StarAlignmentPosition.Center,
            );
          }
          commands.appendBitmapText(text: '\n');
          commands.appendBitmapText(text: '\n');
          commands.appendBitmapText(text: '\n');
          commands.appendCutPaper(StarCutPaperAction.FullCut);
          await StarPrnt.sendCommands(
              portName: port.portName!,
              emulation: emulationFor(port.modelName!),
              printCommands: commands);
          return Future.value();
        }
      }
    } on PlatformException catch (e) {
      showToast(message: e.toString());
    }
  }

  static printToPosPrinter({
    required bool popWidget,
    required PrintReceipt receipt,
    required bool printQR,
    required bool printImage,
  }) async {
    //get pos receipt as bytes and send it to printer
    List<int> receiptBytes = await getPOSReceipt(receipt, printQR, printImage);
    await BluetoothThermalPrinter.writeBytes(receiptBytes);
    //pop the print dialog if it's the first time connecting to printer
    if (popWidget) {
      Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    }
  }

  static Future<List<int>> getPOSReceipt(
      PrintReceipt receipt, bool printQR, bool printImage) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    //check receipt language to print directly or encode the
    //receipt with arabic code page for printer

    ///As sunmi printer doesn't support special characters, so replacing these special characters with alphabets.

    if (receipt.language == 'english') {
      if (!kIsWeb || !isTablet) {
        bytes += generator.text(
            receipt.resultData!
                .toString()
                .replaceAll("é", "e")
                .replaceAll("ų", "u")
                .replaceAll("Ų", "U")
                .replaceAll("ė", "e")
                .replaceAll("Ž", "Z")
                .replaceAll("ž", "z")
                .replaceAll("ū", "u")
                .replaceAll("Ū", "U")
                .replaceAll("š", "s")
                .replaceAll("Ą", "A")
                .replaceAll("ą", "a")
                .replaceAll("Č", "C")
                .replaceAll("č", "c")
                .replaceAll("Ę", "E")
                .replaceAll("ę", "e")
                .replaceAll("Ė", "E")
                .replaceAll("É", "E")
                .replaceAll("ė", "e")
                .replaceAll("Į", "I")
                .replaceAll("į", "i")
                .replaceAll("Š", "S")
                .replaceAll("š", "s")
            ,
            styles: const PosStyles(
              align: PosAlign.left,
            ));
      } else {
        bytes += generator.text(receipt.resultData!.toString(),
            styles: const PosStyles(
              align: PosAlign.left,
            ));
      }
    } else {
      if (receipt.printerType!.toLowerCase().contains('sunmi')) {
        if (!kIsWeb || !isTablet) {
          final encodedStr = const Utf8Encoder().convert(receipt.resultData!
                  .toString()
                  .replaceAll("é", "e")
                  .replaceAll("ų", "u")
                  .replaceAll("Ų", "U")
                  .replaceAll("ė", "e")
                  .replaceAll("Ž", "Z")
                  .replaceAll("ž", "z")
                  .replaceAll("ū", "u")
                  .replaceAll("Ū", "U")
                  .replaceAll("š", "s")
                  .replaceAll("Ą", "A")
                  .replaceAll("ą", "a")
                  .replaceAll("Č", "C")
                  .replaceAll("č", "c")
                  .replaceAll("Ę", "E")
                  .replaceAll("ę", "e")
                  .replaceAll("Ė", "E")
                  .replaceAll("É", "E")
                  .replaceAll("ė", "e")
                  .replaceAll("Į", "I")
                  .replaceAll("į", "i")
                  .replaceAll("Š", "S")
                  .replaceAll("š", "s")
              );
          bytes += generator.textEncoded(
            Uint8List.fromList([
              //first command is to select UTF-8 encoding in the printer
              ...selectCodaPageCommands(receipt.printerType!.toLowerCase()),
              ...encodedStr
            ]),
            styles: const PosStyles(
              align: PosAlign.left,
            ),
            // maxCharsPerLine:
          );
        } else {
          final encodedStr =
              const Utf8Encoder().convert(receipt.resultData!.toString());

          bytes += generator.textEncoded(
            Uint8List.fromList([
              //first command is to select UTF-8 encoding in the printer
              ...selectCodaPageCommands(receipt.printerType!.toLowerCase()),
              ...encodedStr
            ]),
            styles: const PosStyles(
              align: PosAlign.left,
            ),
            // maxCharsPerLine:
          );
        }
      } else {
        bytes += generator.textEncoded(
            Uint8List.fromList([
              //first command is to select the code page in the printer
              // ESC t n where n is the code page number
              ...selectCodaPageCommands(receipt.printerType!.toLowerCase()),
              ...getReceiptCodeUnits(receipt.resultData!),
            ]),
            styles: const PosStyles(
              align: PosAlign.left,
            ));
      }
    }
    if (printImage &&
        receipt.image!.trim().isNotEmpty &&
        receipt.image!.isNotEmpty) {
      final footerImageResponse = await http.get(Uri.parse(receipt.image!));
      final footerImageBytes = footerImageResponse.bodyBytes;
      final img.Image textImage = img.decodeImage(footerImageBytes)!;
      bytes += generator.image(textImage);
    }
    if (printQR && receipt.qrUrl!.trim().isNotEmpty && receipt.qrUrl! != '') {
      bytes += generator.qrcode(receipt.qrUrl!, size: QRSize.Size7);
    }
    bytes += generator.cut();
    return bytes;
  }

  // Generate commands to select code page in printer depending on the printer type
  static List<int> selectCodaPageCommands(String printerType) {
    if (printerType.contains('sunmi')) {
      return [0x1C, 0x26, 0x1C, 0x43, 0xFF];
    } else {
      if (printerType.contains('epson')) {
        return [0x1B, 0x74, 0x25];
      } else {
        if (printerType.contains('ace')) {
          return [0x1B, 0x74, 0x16];
        } else {
          return [0x1B, 0x74, 0x25];
        }
      }
    }
  }

  static List<int> getReceiptCodeUnits(String text) {
    List<int> receiptCodeUnites = [];

    //split the text with breaking lines so we will have each row separately
    List<String> newLineSplitText = text.split('\n');

    //loop each row separately to get the words in it
    for (var rowIndex = 0; rowIndex < newLineSplitText.length; rowIndex++) {
      //split each row with spaces to get the words in that row
      List<String> spacesSplitText = newLineSplitText[rowIndex].split(' ');

      //buffer for each row we are processing
      List<int> rowTextCodeCharacters = [];
      //looping on every character in the row from the end to start because
      // arabic letters are from right to left
      for (var wordIndex = spacesSplitText.length - 1;
          wordIndex >= 0;
          wordIndex--) {
        bool rowEndsWithArabic = false;
        // loop the words in the row to check if the row ends with arabic
        for (var searchWordIndex = spacesSplitText.length - 1;
            searchWordIndex >= 0;
            searchWordIndex--) {
          rowEndsWithArabic = false;
          // If the word we are at index is less than the loop word index
          // continue because the word in the loop is before our word
          if (wordIndex < searchWordIndex) {
            continue;
          }
          // If the word in the loop contains arabic that means
          // the sentence ends in arabic
          if (spacesSplitText[searchWordIndex] != '' &&
              PrinterCodePages.codePage864Start.containsKey(
                  spacesSplitText[searchWordIndex].characters.first)) {
            rowEndsWithArabic = true;
            break;
          }
        }
        // Add spaces between words by determining to add or
        // insert the space depending if the row ends in arabic or not
        if (rowEndsWithArabic) {
          rowTextCodeCharacters.insertAll(0, ' '.codeUnits);
        } else {
          rowTextCodeCharacters.addAll(' '.codeUnits);
        }

        // If the word is space continue because we already added the space
        if (spacesSplitText[wordIndex] == '') {
          continue;
        }

        //check if the word starts with arabic or not
        if (spacesSplitText[wordIndex] != '' &&
            PrinterCodePages.codePage864Start
                .containsKey(spacesSplitText[wordIndex].characters.first)) {
          //buffer for each word to flip it after encoding the word
          List<int> wordFlippingCodeCharactersBuffer = [];

          //loop every word character by character
          for (var characterIndex = 0;
              characterIndex < spacesSplitText[wordIndex].characters.length;
              characterIndex++) {
            List<String> characters =
                spacesSplitText[wordIndex].characters.toList();
            //check if the character is arabic or not
            if (PrinterCodePages.codePage864Start
                .containsKey(characters[characterIndex])) {
              //if character is at the start of the word take it from the start map
              if (characterIndex == 0) {
                wordFlippingCodeCharactersBuffer.add(PrinterCodePages
                    .codePage864Start[characters[characterIndex]]!);
              } else {
                //if character is at the middle of the word take it from the middle map
                if (characterIndex > 0 &&
                    characterIndex < characters.length - 1) {
                  wordFlippingCodeCharactersBuffer.add(PrinterCodePages
                      .codePage864Middle[characters[characterIndex]]!);
                } else {
                  //the character is at the end of the word take it from the end map
                  wordFlippingCodeCharactersBuffer.add(PrinterCodePages
                      .codePage864End[characters[characterIndex]]!);
                }
              }
            } else {
              //if the character is not arabic just add its code units
              receiptCodeUnites.addAll(characters[characterIndex].codeUnits);
            }
          }
          //insert the arabic word at the start of the row buffer for arabic positioning
          rowTextCodeCharacters.insertAll(0, wordFlippingCodeCharactersBuffer);
        } else {
          //word doesn't start with arabic so add reversed code units
          //of it as it will be reverted again to right english word

          if (rowEndsWithArabic) {
            // If the sentence ends with arabic insert the word which
            // here it will be a special character
            rowTextCodeCharacters.insertAll(
                0, spacesSplitText[wordIndex].codeUnits.reversed);
          } else {
            // Sentence doesn't end with arabic add the word don't insert
            rowTextCodeCharacters
                .addAll(spacesSplitText[wordIndex].codeUnits.reversed);
          }
        }
      }
      //add the row reversed code units to the output buffer
      //it's reversed for arabic positioning
      receiptCodeUnites.addAll(rowTextCodeCharacters.reversed);

      //add new line to the final output to preserve the style of the receipt
      receiptCodeUnites.addAll('\n'.codeUnits);
    }
    return receiptCodeUnites;
  }

  static launchPrintToFiskoService(dynamic data) async {
    if (Platform.isAndroid) {
      var platform = const MethodChannel('printFiscal');
      try {
        await platform.invokeMethod('printFiscal', data);
      } on PlatformException catch (_) {
        rethrow;
      }
    }
  }
}

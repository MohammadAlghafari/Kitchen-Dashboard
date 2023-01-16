import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../common/colors.dart';
import 'package:path_provider/path_provider.dart';

import '../common/prefs_keys.dart';
import '../view/screens/login/login_screen.dart';
import 'navigation_service.dart';

void showToast(
    {ToastGravity gravity = ToastGravity.CENTER,
    Color? textColor,
    Color? backgroundColor,
    required String message}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 15.0);
}

String getOnlyDate(DateTime date) {
  return intl.DateFormat('yyyy-MM-dd').format(date);
}
String formatTimeOfDay(TimeOfDay tod, bool isSendingToEndPoints) {
  if(!isSendingToEndPoints){
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = intl.DateFormat.jm();
    return format.format(dt);
  }else{
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = intl.DateFormat.Hms();
    return format.format(dt);
  }
}

// ByteData getBufferCopy(ByteData source) =>
//     Uint8List.fromList(source.buffer.asUint8List()).buffer.asByteData();

String get _getDeviceType {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 550 ? 'phone' : 'tablet';
}

bool get isTablet {
  return _getDeviceType == 'tablet';
}

// Get container border color depending on selected orders filter
Color getContainerFilteredBorderColor(int status) {
  switch (status) {
    case 0:
      return Colors.transparent;
    case 1:
      return MyColors.newOrderColor;
    case 2:
      return MyColors.preparingOrderColor;
    case 3:
      return MyColors.readyOrderColor;
    default:
      return Colors.transparent;
  }
}

// Get color from string
Color hexColor(String? color) {
  var hexColor = color!.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.white;
}

Future<Uint8List> generateImageFromString(
  String text,
  TextAlign align,
  TextDirection textDirection,
) async {
  PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(
      recorder,
      Rect.fromCenter(
        center: const Offset(0, 0),
        width: 540,
        height: 400,
      ));
  TextSpan span = TextSpan(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    text: text,
  );
  TextPainter tp =
      TextPainter(text: span, textAlign: align, textDirection: textDirection);
  tp.layout(minWidth: 540, maxWidth: 540);
  tp.paint(canvas, const Offset(0.0, 0.0));
  var picture = recorder.endRecording();
  final pngBytes = await picture.toImage(
    tp.size.width.toInt(),
    tp.size.height.toInt() - 2, // decrease padding
  );
  final byteData = await pngBytes.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<bool> checkStoragePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

downloadFile(String url, String fileName) async {
  try {
    bool _permissionReady = await checkStoragePermission();
    if (!_permissionReady) return;
    String _localPath =
        (await findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: _localPath,
      fileName: fileName,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    /* if (taskId != null) {
      await OpenFile.open(_localPath + Platform.pathSeparator + fileName,
          type: 'application/vnd.android.package-archive');
    } */
  } catch (e) {
    showToast(message: "the error insider file download is $e");
  }
}

Future<String> findLocalPath() async {
  final directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return directory!.path;
}

Future<Uint8List> generateQrImage(String text) async {
  try {
    final image = await QrPainter(
      data: text,
      version: QrVersions.auto,
      gapless: false,
    ).toImage(200);
    final a = await image.toByteData(format: ImageByteFormat.png);
    return a!.buffer.asUint8List();
  } catch (e) {
    rethrow;
  }
}

handleDioError(DioError e) {

  e.response!.statusCode == 500?
  showToast(
  message: AppLocalizations.of(
  NavigationService.navigatorKey.currentContext!)!
      .server_error)
  :e.response != null &&
          e.response?.data != null &&
          e.response?.data != '' &&
          e.response!.statusCode != 400 &&
          e.response!.statusCode != 401
      ? showToast(message: e.response?.data[PrefsKeys.data] ?? e.response?.data)
      : showToast(
          message: AppLocalizations.of(
                  NavigationService.navigatorKey.currentContext!)!
              .connection_error);
}

saveExcel(Excel excel, String fileName) async {
  if (kIsWeb) {
    excel.save(fileName: fileName + '.xlsx');
  } else {
    bool _permissionReady = await checkStoragePermission();
    if (!_permissionReady) return;
    var fileBytes = excel.save();
    var saveFilePath = await findLocalPath();

    File("$saveFilePath/$fileName.xlsx")
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    if (Platform.isAndroid) {
      File("/storage/emulated/0/Download/$fileName.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}

saveFile(Uint8List fileData, String fileName, String extension,
    MimeType mimeType) async {
  if (kIsWeb) {
    await FileSaver.instance
        .saveFile(fileName, fileData, extension, mimeType: mimeType);
  } else {
    bool _permissionReady = await checkStoragePermission();
    if (!_permissionReady) return;
    var fileBytes = fileData.toList();
    var saveFilePath = await findLocalPath();

    File("$saveFilePath/$fileName.pdf")
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    if (Platform.isAndroid) {
      File("/storage/emulated/0/Download/$fileName.pdf")
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}

//check if the user is not authenticated in response redirect to login page
checkLoginStatus(bool loginStatus) {
  if (!loginStatus) {
    Navigator.of(NavigationService.navigatorKey.currentContext!)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }
}

int getExtendedVersionNumber(String version) {
  List versionCells = version.split('.');
  List intVersionCells = versionCells.map((i) => int.parse(i)).toList();
  var result = (intVersionCells[0] * 100000) +
      (intVersionCells[1] * 1000) +
      (intVersionCells[2]);
  return result;
}


  /* Future<String> getDeviceToken() async {
    String token = await FirebaseMessaging.instance.getToken() ?? '';
    return token;
  } */
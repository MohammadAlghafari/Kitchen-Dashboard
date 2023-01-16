import 'package:flutter/material.dart';

class Setting {
  String appName = '';
  String mainColor;
  String mainDarkColor;
  String secondColor;
  String secondDarkColor;
  String accentColor;
  String accentDarkColor;
  String scaffoldDarkColor;
  String scaffoldColor;
  String googleMapsKey;
  String fcmKey;
  Locale mobileLanguage = const Locale('en', '');
  String appVersion;
  Brightness brightness = Brightness.dark;

  factory Setting.init() {
    return Setting(
        appName: "The Cloud",
        mainColor: "000",
        mainDarkColor: "000",
        secondColor: "000",
        secondDarkColor: "000",
        accentColor: "000",
        accentDarkColor: "000",
        scaffoldDarkColor: "000",
        scaffoldColor: "000",
        googleMapsKey: "000",
        fcmKey: "",
        mobileLanguage: const Locale('en'),
        appVersion: "1.0.0",
        );
  }

  Setting({
    required this.appName,
    required this.mainColor,
    required this.mainDarkColor,
    required this.secondColor,
    required this.secondDarkColor,
    required this.accentColor,
    required this.accentDarkColor,
    required this.scaffoldDarkColor,
    required this.scaffoldColor,
    required this.googleMapsKey,
    required this.fcmKey,
    required this.mobileLanguage,
    required this.appVersion,
  });

  factory Setting.fromJSON(Map<String, dynamic> jsonMap) {
    List<String> _homeSections = [];
    for (int _i = 1; _i <= 12; _i++) {
      _homeSections.add(jsonMap['home_section_' + _i.toString()] ?? 'empty');
    }
    return Setting(
        appName: jsonMap['app_name'],
        mainColor: jsonMap['main_color'],
        mainDarkColor: jsonMap['main_dark_color'] ?? '',
        secondColor: jsonMap['second_color'] ?? '',
        secondDarkColor: jsonMap['second_dark_color'] ?? '',
        accentColor: jsonMap['accent_color'] ?? '',
        accentDarkColor: jsonMap['accent_dark_color'] ?? '',
        scaffoldDarkColor: jsonMap['scaffold_dark_color'] ?? '',
        scaffoldColor: jsonMap['scaffold_color'] ?? '',
        googleMapsKey: jsonMap['google_maps_key'],
        fcmKey: jsonMap['fcm_key'],
        mobileLanguage: Locale(jsonMap['mobile_language'] ?? "en", ''),
        appVersion: jsonMap['app_version'] ?? '',
        );
  }

  Map toMap() {
    var map =  <String, dynamic>{};
    map["app_name"] = appName;
    map["mobile_language"] = mobileLanguage.languageCode;
    return map;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/navigation_service.dart';
import 'home_view_model.dart';
import '../common/prefs_keys.dart';

import '../infrastructure/settings/model/setting.dart';

class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  Setting setting = Setting.init();
  SettingsViewModel({required this.prefs}) {
    loadSettings();
  }
  loadSettings() {
    setUserSettings();
    notifyListeners();
  }

  setUserSettings() {
    if (prefs.getBool(PrefsKeys.darkTheme) != null &&
        !prefs.getBool(PrefsKeys.darkTheme)!) {
      setting.brightness = Brightness.light;
      prefs.setBool(PrefsKeys.darkTheme, false);
    } else {
      prefs.setBool(PrefsKeys.darkTheme, true);
    }
    if (prefs.getString(PrefsKeys.languageCode) != null) {
      setting.mobileLanguage = Locale(prefs.getString(PrefsKeys.languageCode)!);
    } else {
      prefs.setString(PrefsKeys.languageCode, 'en');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    prefs.setString(PrefsKeys.languageCode, languageCode);
    setting.mobileLanguage = Locale(languageCode);
    notifyListeners();
    Provider.of<HomeViewModel>(NavigationService.navigatorKey.currentContext!, listen: false)
        .getOrders();
  }

  void changeBrightness() async {
    if (prefs.getBool(PrefsKeys.darkTheme) != null &&
        prefs.getBool(PrefsKeys.darkTheme)!) {
      prefs.setBool(PrefsKeys.darkTheme, false);
      setting.brightness = Brightness.light;
    } else {
      prefs.setBool(PrefsKeys.darkTheme, true);
      setting.brightness = Brightness.dark;
    }
    notifyListeners();
  }
}

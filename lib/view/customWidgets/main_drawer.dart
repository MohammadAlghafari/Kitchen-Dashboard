import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/common/images.dart';
import 'package:thecloud/common/prefs_keys.dart';
import 'package:thecloud/view/customWidgets/close_kitchen_dialog.dart';
import 'package:thecloud/view/screens/home/home_screen.dart';
import 'package:thecloud/view/screens/inventory/inventory_screen.dart';
import 'package:thecloud/view/screens/ordersHistory/orders_history_screen.dart';
import 'package:thecloud/view/screens/ordersStatistics/orders_statistics_screen.dart';
import 'package:thecloud/viewModels/inventory_view_model.dart';
import 'package:thecloud/viewModels/settings_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/colors.dart';
import '../../viewModels/auth_view_model.dart';
import 'confirmation_dialog.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return Drawer(
      child: Consumer<SettingsViewModel>(
          builder: (context, settingsViewModel, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                Images.appIcon,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  Provider.of<AuthViewModel>(context, listen: false)
                      .sharedPreferences
                      .getString(PrefsKeys.kitchenName)!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.home,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacementNamed(HomeScreen.routeName);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.inventory_2_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.inventory,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(InventoryScreen.routeName);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.orders_history,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(OrdersHistoryScreen.routeName);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.stacked_bar_chart_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.menu_statistics,
                  style: TextStyle(
                      color: MyColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(OrdersStatisticsScreen.routeName);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.translate_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  settingsViewModel.setting.mobileLanguage.languageCode == 'en'
                      ? 'العربية'
                      : 'English',
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () async {
                  bool language =
                      settingsViewModel.setting.mobileLanguage.languageCode ==
                          'en';
                  await settingsViewModel
                      .changeLanguage(language ? 'ar' : 'en');
                  Provider.of<InventoryViewModel>(context, listen: false).searchAvailability(language == true? 'الكل' : 'All');
                  Navigator.of(context).pushReplacementNamed(ModalRoute.of(context)!.settings.name.toString());
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.brightness_6_outlined,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  settingsViewModel.setting.brightness == Brightness.light
                      ? _trans.dark_theme
                      : _trans.white_theme,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  settingsViewModel.changeBrightness();
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.key_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.close_kitchen,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => const CloseKitchenDialog());
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(context).focusColor.withOpacity(1),
                ),
                title: Text(
                  _trans.log_out,
                  style: TextStyle(color: MyColors.green,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                          content: _trans.are_you_sure_you_want_to_logout,
                          confirmFunction: () {
                            Provider.of<AuthViewModel>(context, listen: false)
                                .logout();
                          }));
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

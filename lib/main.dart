import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'common/themes.dart';
import 'view/screens/login/login_screen.dart';
import 'injection_container.dart' as di;
import 'util/navigation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakelock/wakelock.dart';

import 'route_generator.dart';
import 'viewModels/auth_view_model.dart';
import 'viewModels/home_view_model.dart';
import 'viewModels/inventory_view_model.dart';
import 'viewModels/orders_history_view_model.dart';
import 'viewModels/orders_statistics_view_model.dart';
import 'viewModels/settings_view_model.dart';

/* Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
} */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /* await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService.initializeNotifications(); */
  if (!kIsWeb) {
    await FlutterDownloader.initialize(
        debug: true,
        // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
  }
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  /* final SharedPreferences _sharedPreferences =
      di.serviceLocator<SharedPreferences>(); */

  @override
  void initState() {
    super.initState();
    //and enable wake lock to stop screen from going to sleep
    if (!kIsWeb) {
      // _sharedPreferences.remove(PrefsKeys.authenticated);
      Wakelock.enable();
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => di.serviceLocator<SettingsViewModel>()),
        ChangeNotifierProvider(
            create: (context) => di.serviceLocator<InventoryViewModel>()),
        ChangeNotifierProvider(
            create: (context) => di.serviceLocator<OrdersHistoryViewModel>()),
        ChangeNotifierProvider(
            create: (context) =>
                di.serviceLocator<OrdersStatisticsViewModel>()),
        ChangeNotifierProvider(
            create: (context) => di.serviceLocator<HomeViewModel>()),
        ChangeNotifierProvider(
            create: (context) => di.serviceLocator<AuthViewModel>()),
      ],
      child: Consumer<SettingsViewModel>(builder: (context, settings, child) {
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            title: 'The Cloud',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: settings.setting.mobileLanguage,
            supportedLocales: const [
              Locale("ar", ''),
              Locale("en", ''),
            ],
            theme: settings.setting.brightness == Brightness.dark
                ? Themes.darkTheme(context)
                : Themes.whiteTheme(context),
            //generate routes using the route generator class
            onGenerateRoute: RouteGenerator.generateRoute,
            onUnknownRoute: (settings) => MaterialPageRoute(
                builder: (_) => const LoginScreen(), settings: settings),
          );
      }),
    );
  }
}

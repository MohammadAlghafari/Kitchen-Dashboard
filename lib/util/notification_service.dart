/* import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../navigation_service.dart';
import '../viewModels/home_view_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static void initializeNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      Provider.of<HomeViewModel>(NavigationService.navigatorKey.currentContext!,
              listen: false)
          .getOrders();
      // Provider notify
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Provider notify
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      // Provider notify

      return;
    });
  }

  static void iOS_Permission() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<dynamic> onSelectNotification(String payload) async {
    /*Do whatever you want to do on notification click. In this case, I'll show an alert dialog*/
  }

  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  static void selectNotification(String? payload) {}
}
 */
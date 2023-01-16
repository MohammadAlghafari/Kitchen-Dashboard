import UIKit
import Flutter
//import Firebase
//import UserNotifications
import flutter_downloader
//import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //if #available(iOS 10.0, *) {
     //   UNUserNotificationCenter.current().delegate = self
     // }
    //FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
GeneratedPluginRegistrant.register(with: registry)
}

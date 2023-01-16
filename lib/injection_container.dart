import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/infrastructure/home/api/confirm_special_message_api.dart';
import 'package:thecloud/infrastructure/home/api/delivery_driver_arrived_api.dart';
import 'package:thecloud/infrastructure/home/api/get_app_version.dart';
import 'package:thecloud/infrastructure/home/api/get_qr_code_file_name.dart';
import 'package:thecloud/infrastructure/home/api/temporary_close_kitchen_api.dart';
import 'package:thecloud/infrastructure/home/api/update_order_display_time_api.dart';
import 'package:thecloud/infrastructure/inventory/api/change_addon_availability_api.dart';
import 'package:thecloud/infrastructure/inventory/api/change_inventory_item_availability_api.dart';
import 'package:thecloud/infrastructure/inventory/api/get_inventory_items_addons_api.dart';
import 'package:thecloud/infrastructure/inventory/api/get_inventory_items_api.dart';
import 'package:thecloud/infrastructure/inventory/inventory_repository.dart';
import 'package:thecloud/infrastructure/ordersHistory/api/get_orders_history_api.dart';
import 'package:thecloud/infrastructure/ordersHistory/api/undo_order_status_api.dart';
import 'package:thecloud/infrastructure/ordersHistory/orders_history_repository.dart';
import 'package:thecloud/infrastructure/ordersStatistics/api/get_orders_statistics_api.dart';
import 'package:thecloud/infrastructure/ordersStatistics/orders_statistics_repository.dart';
import 'package:thecloud/viewModels/inventory_view_model.dart';
import 'package:thecloud/viewModels/orders_history_view_model.dart';
import 'package:thecloud/viewModels/orders_statistics_view_model.dart';
import 'infrastructure/auth/api/reset_password_api.dart';
import 'infrastructure/home/api/update_cancel_order_request_api.dart';
import 'infrastructure/home/api/update_order_item_status_api.dart';
import 'infrastructure/home/api/get_print_receipt_api.dart';
import 'infrastructure/home/api/periodic_check_orders_api.dart';
import 'infrastructure/auth/api/logout_api.dart';
import 'common/prefs_keys.dart';
import 'infrastructure/home/api/get_orders_api.dart';
import 'infrastructure/home/api/update_order_status_api.dart';
import 'infrastructure/home/home_repository.dart';
import 'infrastructure/auth/api/login_api.dart';
import 'infrastructure/auth/auth_repository.dart';
import 'viewModels/auth_view_model.dart';
import 'viewModels/home_view_model.dart';
import 'viewModels/settings_view_model.dart';

import 'infrastructure/apiUtil/urls.dart';
import 'infrastructure/catalog_facade_service.dart';

final GetIt serviceLocator = GetIt.instance;

// register all components to get it to inject the dependencies where we need it
Future<void> init() async {
  //core
  await registerCoreComponents();

  //catalog
  registerCatalog();

  //viewModel
  registerViewModel();

  //repository
  registerRepository();

  //ApiCall
  registerApiCalls();
}

registerApiCalls() {
  serviceLocator.registerLazySingleton(() => LoginApi(
        dio: serviceLocator(),
      ));
  serviceLocator.registerLazySingleton(() => ResetPasswordApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => LogoutApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => PeriodicCheckOrdersApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetOrdersApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => UpdateOrderStatusApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => UpdateOrderItemStatusApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => UpdateOrderDisplayTimeApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => UpdateCancelOrderRequestApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetAppVersionApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetPrintReceiptApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetInventoryItemsApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetOrdersHistoryApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetOrdersStatisticsApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => UndoOrderStatusApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => ChangeInventoryItemAvailabilityApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => ChangeInventoryItemAddonsAvailabilityApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => GetInventoryItemAddonsApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => DeliveryGuyArrivedApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => TemporaryCloseKitchenApi(
        dio: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => ConfirmSpecialMessageApi(
        dio: serviceLocator(),
      ));
  serviceLocator.registerLazySingleton(() => GetQrCodeFileNameApi(
        dio: serviceLocator(),
      ));
}

registerViewModel() {
  serviceLocator.registerLazySingleton(() => SettingsViewModel(
        prefs: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => InventoryViewModel(
        catalogFacadeService: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => OrdersHistoryViewModel(
        catalogFacadeService: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => OrdersStatisticsViewModel(
        catalogFacadeService: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => AuthViewModel(
        catalogFacadeService: serviceLocator(),
        secureStorage: serviceLocator(),
        sharedPreferences: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => HomeViewModel(
        catalogFacadeService: serviceLocator(),
      ));
}

registerRepository() {
  serviceLocator.registerLazySingleton(() => AuthRepository(
        loginApi: serviceLocator(),
        logoutApi: serviceLocator(),
        resetPasswordApi: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => InventoryRepository(
        getInventoryItemsApi: serviceLocator(),
        changeInventoryItemAvailabilityApi: serviceLocator(),
        getInventoryItemAddonsApi: serviceLocator(),
        changeInventoryItemAddonsAvailabilityApi: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => OrdersHistoryRepository(
        getOrdersHistoryApi: serviceLocator(),
        undoOrderStatusApi: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => OrdersStatisticsRepository(
        getOrdersStatisticsApi: serviceLocator(),
      ));

  serviceLocator.registerLazySingleton(() => HomeRepository(
        getOrdersApi: serviceLocator(),
        updateOrderStatusApi: serviceLocator(),
        periodicCheckOrdersApi: serviceLocator(),
        updateOrderDisplayTimeApi: serviceLocator(),
        printReceiptApi: serviceLocator(),
        updateOrderItemStatusApi: serviceLocator(),
        updateCancelOrderRequestApi: serviceLocator(),
        getAppVersionApi: serviceLocator(),
        deliveryGuyArrivedApi: serviceLocator(),
        temporaryCloseKitchenApi: serviceLocator(),
        confirmSpecialMessageApi: serviceLocator(),
        getQrCodeFileNameApi: serviceLocator(),
      ));
}

registerCatalog() {
  serviceLocator.registerLazySingleton(() => CatalogFacadeService(
        authRepository: serviceLocator(),
        homeRepository: serviceLocator(),
        inventoryRepository: serviceLocator(),
        ordersHistoryRepository: serviceLocator(),
        ordersStatisticsRepository: serviceLocator(),
      ));
}

registerCoreComponents() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(PrefsKeys.languageCode)) {
    prefs.setString(PrefsKeys.languageCode, 'en');
  }
  serviceLocator.registerLazySingleton(() => prefs);

  serviceLocator.registerLazySingleton(() => const FlutterSecureStorage());

  serviceLocator.registerLazySingleton(() => getNetworkObj());
}

Dio getNetworkObj() {
  BaseOptions options = BaseOptions(
    baseUrl: Urls.kBaseUrl,
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );
  Dio dio = Dio(options);

  //intercept every api request and add needed headers to it
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? apiToken;
        if (kIsWeb) {
          apiToken =
              serviceLocator<SharedPreferences>().getString(PrefsKeys.apiToken);
        } else {
          apiToken = await serviceLocator<FlutterSecureStorage>()
              .read(key: PrefsKeys.apiToken);
        }

        String? languageCode = serviceLocator<SharedPreferences>()
            .getString(PrefsKeys.languageCode);
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        options.headers['web-data'] = kIsWeb;

        //don't send api token of the path is login
        //if (apiToken != null && options.path != '/api/login.php') {
        options.headers['Authorization'] = 'Bearer $apiToken';
        //}
        options.headers['language-code'] = languageCode;
        options.headers['local-time'] = DateTime.now();
        options.headers['mac-address'] = await PlatformDeviceId.getDeviceId;
        //options.headers['Access-Control-Allow-Origin'] = '*';

        handler.next(options);
      },
    ),
  );

  //dio logger to see every request and response
  //on the debug console, remove on release!!!
  dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90));
  return dio;
}

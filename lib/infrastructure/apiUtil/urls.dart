class Urls {
  // static const String baseUrl = 'https://staging-kitchen.thecloud.ae/';
  // static const String baseUrl = 'http://128.199.218.211/';
  // static const String kBaseUrl = 'https://staging-kitchen-api.thecloud.ae';
  //
  ///Use the following URL when releasing the live app.
  static const String kBaseUrl = 'https://kitchen-api.thecloud.ae';

  static const String login = '/api/login.php';
  static const String resetPassword = '/api/resetPassword.php';
  static const String getAllOrders = '/api/orders.php';
  static const String getInventoryItems = '/api/kitchenMenu.php';
  static const String changeInventoryItemAvailability = '/api/kitchenMenu.php';
  static const String getAndChangeAddonItemAvailability = '/api/kitchenMenuAddons.php';
  static const String getAppVersion = '/api/latestRelease.php';
  static const String getQrCodeFileName = '/api/QR_code.php';
  static const String downloadInvoice = '/api/download_invoice.php';
  static const String getOrdersHistory = '/api/orderHistory.php';
  static const String undoOrderStatus = '/api/orderHistory.php';
  static const String getOrdersStatistics = '/api/menuSummary.php';
  static const String periodicCheckOrders = '/api/updates.php';
  static const String updateOrderStatus = '/api/orders.php';
  static const String updateOrderItemStatus = '/api/orders.php';
  static const String updateCancelOrderRequest = '/api/orders.php';
  static const String deliveryGuyArrived = '/api/riderArrivedKitchen.php';
  static const String printReceipt = '/api/print.php';
  static const String pdf = '/api/download_invoice.php';
  static const String closeKitchen = '/api/temporary_close_kitchen.php';
  static const String confirmSpecialMessage = '/api/special_message.php';
}

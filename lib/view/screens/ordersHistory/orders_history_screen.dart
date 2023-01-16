import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/common/prefs_keys.dart';
import 'package:thecloud/view/customWidgets/main_drawer.dart';
import 'package:thecloud/view/screens/ordersHistory/widgets/order_history_list_item.dart';
import 'package:thecloud/viewModels/orders_history_view_model.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../util/global_functions.dart';
import '../../../viewModels/settings_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';
import '../../customWidgets/confirmation_dialog.dart';
import '../../customWidgets/drop_down_text_field.dart';
import '../../customWidgets/no_data_widget.dart';
import '../../customWidgets/page_indicator_chip.dart';
import '../../customWidgets/server_error_widget.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({Key? key}) : super(key: key);
  static const routeName = '/orders_history_screen';

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  TextEditingController startDateController =
      TextEditingController(text: getOnlyDate(DateTime.now()));
  TextEditingController endDateController =
      TextEditingController(text: getOnlyDate(DateTime.now()));
  late TextEditingController orderIdController;
  late TextEditingController platformController;
  late TextEditingController startTimeController = TextEditingController();
  late TextEditingController endTimeController = TextEditingController();
  late TextEditingController statusController;
  late AutoScrollController scrollController;
  SharedPreferences? preferences;
  String? columnId = '';
  String? itemsOrder = '';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String startTime = "12:00 AM";
  String endTime = "11:59 PM";

  @override
  void initState() {
    super.initState();
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.horizontal);
    orderIdController = TextEditingController(text: '');
    platformController = TextEditingController(text: '');
    statusController = TextEditingController(text: '');
    startTimeController.text = startTime;
    endTimeController.text = endTime;
    // endTimeController = TextEditingController(text: '');
    getPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<OrdersHistoryViewModel>(context, listen: false)
            .getOrdersHistory());
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    orderIdController.dispose();
    platformController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void getPreferences() async {
    try {
      preferences = await SharedPreferences.getInstance();
      if (preferences!.getString(PrefsKeys.orderHistoryStartDate)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.orderHistoryStartDate)! != null) {
        startDateController.text =
            preferences!.getString(PrefsKeys.orderHistoryStartDate).toString();
      } else {
        startDateController =
            TextEditingController(text: getOnlyDate(DateTime.now()));
      }
      if (preferences!.getString(PrefsKeys.orderHistoryStartTime)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.orderHistoryStartTime)! != null) {
        startTimeController.text =
            preferences!.getString(PrefsKeys.orderHistoryStartTime).toString();
      } else {
        startTimeController.text = startTime;
      }
      if (preferences!.getString(PrefsKeys.orderHistoryEndDate)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.orderHistoryEndDate)! != null) {
        endDateController.text =
            preferences!.getString(PrefsKeys.orderHistoryEndDate).toString();
      } else {
        endDateController =
            TextEditingController(text: getOnlyDate(DateTime.now()));
      }
      if (preferences!.getString(PrefsKeys.orderHistoryEndTime)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.orderHistoryEndTime)! != null) {
        startTimeController.text =
            preferences!.getString(PrefsKeys.orderHistoryEndTime).toString();
      } else {
        endTimeController.text = endTime;
      }
    } catch (e) {
      if (kDebugMode) {
        print("catch exception: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    var brightness = Provider.of<SettingsViewModel>(context, listen: true)
        .setting
        .brightness;
    bool isDarkMode = brightness == Brightness.dark;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          drawer: const MainDrawer(),
          appBar: AppBar(
            backgroundColor: isDarkMode? MyColors.white.withOpacity(0.1):MyColors.white,
            title: Image.asset(
              Images.appIcon,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            centerTitle: false,
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      Images.appIcon,
                    ),
                    // colorFilter: ColorFilter.mode(Colors.black12, BlendMode.dstATop),
                    opacity: 0.03
                )
            ),
            child: Consumer<OrdersHistoryViewModel>(
              builder: (context, ordersHistoryViewModel, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (ordersHistoryViewModel.numberOfPages > 1) {
                    scrollController
                        .scrollToIndex(ordersHistoryViewModel.pageNumber - 1);
                  }
                });
                return ordersHistoryViewModel.isLoading
                    ? const LoadingIconWidget()
                    : ordersHistoryViewModel.isError
                        ? ServerErrorWidget(
                            onTap: () =>
                                ordersHistoryViewModel.getOrdersHistory(),
                          )
                        : RefreshIndicator(
                            onRefresh: () {
                              preferences!
                                  .remove(PrefsKeys.orderHistoryStartDate);
                              preferences!
                                  .remove(PrefsKeys.orderHistoryStartDate);
                              preferences!
                                  .remove(PrefsKeys.orderHistoryStartTime);
                              preferences!
                                  .remove(PrefsKeys.orderHistoryEndTime);
                              orderIdController.text = '';
                              platformController.text = '';
                              statusController.text = '';
                              startTimeController.text = startTime;
                              endTimeController.text = endTime;
                              startDateController.text =
                                  getOnlyDate(DateTime.now());
                              endDateController.text =
                                  getOnlyDate(DateTime.now());
                              return ordersHistoryViewModel.getOrdersHistory();
                            },
                            color: MyColors.green,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                        fit: FlexFit.tight,
                                        child: Text(
                                          _trans.orders_history,
                                          style: const TextStyle(
                                            fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                        child: Text(_trans.export_order_history),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  ConfirmationDialog(
                                                      content: _trans
                                                          .export_order_history,
                                                      confirmFunction: () {
                                                        ordersHistoryViewModel
                                                            .exportOrdersHistory();
                                                      }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: MyColors.green)),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? MyColors.backgroundLevel0
                                        : MyColors.grey,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _trans.start_date,
                                                style: const TextStyle(fontSize: kIsWeb? 14: 12),
                                              ),
                                              // const SizedBox(
                                              //   width: 10,
                                              // ),
                                              SizedBox(
                                                width: kIsWeb? 160:150,
                                                child: DropDownTextField(
                                                  hintText: _trans.start_date,
                                                  controller: startDateController,
                                                  handleTap: () async {
                                                    var date = await showDatePicker(

                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2020),
                                                        lastDate: DateTime.now());
                                                    if (date != null) {
                                                      startDate = date;
                                                      ordersHistoryViewModel
                                                          .changeStartDate(
                                                              getOnlyDate(date));
                                                      startDateController.text =
                                                          ordersHistoryViewModel
                                                              .startDate;
                                                      preferences!.setString(
                                                          PrefsKeys
                                                              .orderHistoryStartDate,
                                                          startDateController.text);
                                                    }
                                                  },
                                                ),
                                              ),

                                              if(kIsWeb)
                                              const SizedBox(
                                                width: 10,
                                              ),

                                              // if(kIsWeb)
                                              if(kIsWeb)
                                              SizedBox(
                                                width: 155,
                                                child: DropDownTextField(
                                                  hintText: _trans.start_time,
                                                  controller: startTimeController,
                                                  handleTap: () async {
                                                    var time = await showTimePicker(
                                                        context: context,
                                                        initialTime: TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      // startTime = time.toString();
                                                      ordersHistoryViewModel
                                                          .changeStartTime(
                                                          formatTimeOfDay(time, false));
                                                      ordersHistoryViewModel
                                                          .changeStartTimeForApi(
                                                          time);
                                                      startTimeController.text =
                                                          ordersHistoryViewModel.startTime;
                                                      preferences!.setString(
                                                          PrefsKeys
                                                              .orderHistoryStartTime,
                                                          startTimeController.text);
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _trans.end_date,
                                                style: const TextStyle(fontSize: kIsWeb? 14: 12),
                                              ),
                                              // const SizedBox(
                                              //   width: 10,
                                              // ),
                                              SizedBox(
                                                width: kIsWeb? 160:150,
                                                child: DropDownTextField(
                                                  hintText: _trans.end_date,
                                                  controller: endDateController,

                                                  handleTap: () async {
                                                    var date = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2020),
                                                        lastDate: DateTime.now());
                                                    if (date != null) {
                                                      endDate = date;
                                                      ordersHistoryViewModel
                                                          .changeEndDate(
                                                              getOnlyDate(date));
                                                      endDateController.text =
                                                          ordersHistoryViewModel
                                                              .endDate;
                                                      preferences!.setString(
                                                          PrefsKeys
                                                              .orderHistoryEndDate,
                                                          endDateController.text);
                                                    }
                                                  },
                                                ),
                                              ),

                                              if(kIsWeb)
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              if(kIsWeb)
                                              SizedBox(
                                                width: 160,
                                                child: DropDownTextField(
                                                  hintText: _trans.end_time,
                                                  controller: endTimeController,
                                                  handleTap: () async {
                                                    var time = await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      // endTime = time.toString();
                                                      ordersHistoryViewModel
                                                          .changeEndTime(
                                                          formatTimeOfDay(time, false));
                                                      ordersHistoryViewModel
                                                          .changeStartTimeForApi(
                                                          time);
                                                      endTimeController.text =
                                                          ordersHistoryViewModel.endTime;
                                                      preferences!.setString(
                                                          PrefsKeys
                                                              .orderHistoryEndTime,
                                                          endTimeController.text);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                              height: 40,
                                              width: 190,
                                              child: TextField(
                                                controller: orderIdController,
                                                maxLines: 1,
                                                cursorColor: MyColors.green,
                                                style: TextStyle(
                                                    color: MyColors.black),
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                        borderSide:
                                                            BorderSide.none),
                                                    hintText: _trans.order_id,
                                                    fillColor: Colors.white),
                                              )),
                                          const Spacer(),
                                          ElevatedButton(
                                            child: Text(_trans.clear),
                                            onPressed: () {
                                              ordersHistoryViewModel
                                                  .getOrdersHistory();
                                              preferences!.remove(PrefsKeys
                                                  .orderHistoryStartDate);
                                              preferences!.remove(
                                                  PrefsKeys.orderHistoryEndDate);
                                              preferences!.remove(PrefsKeys
                                                  .orderHistoryStartTime);
                                              preferences!.remove(
                                                  PrefsKeys.orderHistoryEndTime);
                                                preferences!.remove(PrefsKeys
                                                  .orderHistoryStartTimeForApi);
                                              preferences!.remove(
                                                  PrefsKeys.orderHistoryEndTimeForApi);
                                              orderIdController.text = '';
                                              platformController.text = '';
                                              statusController.text = '';
                                              startDateController.text =
                                                  getOnlyDate(DateTime.now());
                                              endDateController.text =
                                                  getOnlyDate(DateTime.now());
                                              startTimeController.text = startTime;
                                              endTimeController.text = endTime;
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: MyColors.paleRed),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          ElevatedButton(
                                            child: Text(_trans.search),
                                            onPressed: () {
                                              if (endDate.isBefore(startDate)) {
                                                showToast(
                                                    message: _trans
                                                        .select_valid_dates);
                                              } else {
                                                ordersHistoryViewModel
                                                    .searchOrderHistory(
                                                  orderId: orderIdController.text,
                                                  platform: platformController.text,
                                                  status: statusController.text,
                                                  columnId: columnId,
                                                  itemsOrder: itemsOrder,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: MyColors.green),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                                height: 40,
                                                width: 190,
                                                child: TextField(
                                                  controller: platformController,
                                                  maxLines: 1,
                                                  cursorColor: MyColors.green,
                                                  style: TextStyle(
                                                      color: MyColors.black),
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              BorderSide.none),
                                                      hintText: _trans.platform,
                                                      fillColor: Colors.white),
                                                )),
                                            SizedBox(
                                              height: 40,
                                              width: 145,
                                              child: TextField(
                                                controller: statusController,
                                                maxLines: 1,
                                                cursorColor: MyColors.green,
                                                style: TextStyle(
                                                  color: MyColors.black,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  hintText: _trans.status,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _trans.order_id,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if(kIsWeb)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                                onTap: (){
                                                  // ordersHistoryViewModel.sortOrderHistory("increment", "asc");
                                                  columnId = 'increment';
                                                  itemsOrder = 'asc';
                                                  ordersHistoryViewModel.searchOrderHistory(
                                                    orderId: orderIdController.text,
                                                    platform: platformController.text,
                                                    status: statusController.text,
                                                    columnId: columnId,
                                                    itemsOrder: itemsOrder,
                                                  );
                                                },
                                                child: const Icon(Icons.arrow_drop_up_sharp, size: 30,)),
                                            GestureDetector(
                                                onTap: (){
                                                  // ordersHistoryViewModel.sortOrderHistory("increment", "desc");
                                                  columnId = 'increment';
                                                  itemsOrder = 'desc';
                                                  ordersHistoryViewModel.searchOrderHistory(
                                                    orderId: orderIdController.text,
                                                    platform: platformController.text,
                                                    status: statusController.text,
                                                    columnId: columnId,
                                                    itemsOrder: itemsOrder,
                                                  );
                                                },
                                                child: const Icon(Icons.arrow_drop_down, size: 30,)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: isTablet ? 50 : 30,
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Text(
                                        _trans.order_items,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (isTablet)
                                      Row(
                                        children: [
                                          Text(
                                            _trans.kitchen_name,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // SizedBox(width: 10,),
                                          if(kIsWeb)
                                          Column(
                                            children: [
                                              GestureDetector(
                                                  onTap: (){
                                                    // ordersHistoryViewModel.sortOrderHistory("kitchen", "asc");
                                                    columnId = 'kitchen';
                                                    itemsOrder = 'asc';
                                                    ordersHistoryViewModel.searchOrderHistory(
                                                      orderId: orderIdController.text,
                                                      platform: platformController.text,
                                                      status: statusController.text,
                                                      columnId: columnId,
                                                      itemsOrder: itemsOrder,
                                                    );
                                                  },
                                                  child: const Icon(Icons.arrow_drop_up_sharp, size: 30,)),
                                              GestureDetector(
                                                  onTap: (){
                                                    // ordersHistoryViewModel.sortOrderHistory("kitchen", "desc");
                                                    columnId = 'kitchen';
                                                    itemsOrder = 'desc';
                                                    ordersHistoryViewModel.searchOrderHistory(
                                                      orderId: orderIdController.text,
                                                      platform: platformController.text,
                                                      status: statusController.text,
                                                      columnId: columnId,
                                                      itemsOrder: itemsOrder,
                                                    );
                                                  },
                                                  child: const Icon(Icons.arrow_drop_down, size: 30,)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if (isTablet)
                                      const SizedBox(
                                        width: 60,
                                      ),
                                    if (isTablet)
                                      Row(
                                        children: [
                                          Text(
                                            _trans.brand,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if(kIsWeb)
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                  onTap: (){
                                                    // ordersHistoryViewModel.sortOrderHistory("brand", "asc");
                                                    columnId = 'brand';
                                                    itemsOrder = 'asc';
                                                    ordersHistoryViewModel.searchOrderHistory(
                                                      orderId: orderIdController.text,
                                                      platform: platformController.text,
                                                      status: statusController.text,
                                                      columnId: columnId,
                                                      itemsOrder: itemsOrder,
                                                    );
                                                  },
                                                  child: const Icon(Icons.arrow_drop_up_sharp, size: 30,)),
                                              GestureDetector(
                                                  onTap: (){
                                                    // ordersHistoryViewModel.sortOrderHistory("brand", "desc");
                                                    columnId = 'brand';
                                                    itemsOrder = 'desc';
                                                    ordersHistoryViewModel.searchOrderHistory(
                                                      orderId: orderIdController.text,
                                                      platform: platformController.text,
                                                      status: statusController.text,
                                                      columnId: columnId,
                                                      itemsOrder: itemsOrder,
                                                    );
                                                  },
                                                  child: const Icon(Icons.arrow_drop_down, size: 30,)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if (isTablet)
                                      const SizedBox(
                                        width: 70,
                                      ),
                                    Text(
                                      _trans.price,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _trans.status,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if(kIsWeb)
                                        Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                                onTap: (){
                                                  // ordersHistoryViewModel.sortOrderHistory("status", "asc");
                                                  columnId = 'status';
                                                  itemsOrder = 'asc';
                                                  ordersHistoryViewModel.searchOrderHistory(
                                                    orderId: orderIdController.text,
                                                    platform: platformController.text,
                                                    status: statusController.text,
                                                    columnId: columnId,
                                                    itemsOrder: itemsOrder,
                                                  );
                                                },
                                                child: const Icon(Icons.arrow_drop_up_sharp, size: 30,)),
                                            GestureDetector(
                                                onTap: (){
                                                  // ordersHistoryViewModel.sortOrderHistory("status", "desc");
                                                  columnId = 'status';
                                                  itemsOrder = 'desc';
                                                  ordersHistoryViewModel.searchOrderHistory(
                                                    orderId: orderIdController.text,
                                                    platform: platformController.text,
                                                    status: statusController.text,
                                                    columnId: columnId,
                                                    itemsOrder: itemsOrder,
                                                  );
                                                },
                                                child: const Icon(Icons.arrow_drop_down, size: 30,)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: isTablet ? 60 : 30,
                                    ),
                                    if (isTablet)
                                      Text(
                                        _trans.payment,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (isTablet)
                                      const SizedBox(
                                        width: 30,
                                      ),
                                    Text(
                                      _trans.undo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 5,
                                ),
                                ordersHistoryViewModel.ordersHistory!.isEmpty
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          NoDataWidget(
                                            onTap: () => ordersHistoryViewModel
                                                .getOrdersHistory(),
                                          ),
                                        ],
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (context, index) =>
                                              Column(
                                                children: [
                                                  OrderHistoryListItem(
                                                      orderHistoryModel:
                                                          ordersHistoryViewModel
                                                              .ordersHistory![index]),
                                                  const Divider(),
                                                ],
                                              ),
                                          itemCount: ordersHistoryViewModel
                                              .ordersHistory!.length,
                                          shrinkWrap: true,
                                        ),
                                      ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (ordersHistoryViewModel.numberOfPages > 1)
                                  Align(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    child: SizedBox(
                                      height: 30,
                                      width: kIsWeb ? 500 : 300,
                                      child: ListView.builder(
                                        controller: scrollController,
                                        itemBuilder: (context, index) =>
                                            AutoScrollTag(
                                          key: ValueKey(index),
                                          index: index,
                                          controller: scrollController,
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.only(
                                                    end: 5),
                                            child: PageIndicatorChip(
                                              pageNumber: (index + 1).toString(),
                                              isSelected: (index + 1) ==
                                                  ordersHistoryViewModel
                                                      .pageNumber,
                                              onTap: () {
                                                ordersHistoryViewModel
                                                    .searchPage(index + 1, columnId!, itemsOrder!);
                                              },
                                            ),
                                          ),
                                        ),
                                        itemCount:
                                            ordersHistoryViewModel.numberOfPages,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          );
              },
            ),
          ),
        ),
      ),
    );
  }
}

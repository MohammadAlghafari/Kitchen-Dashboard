import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/common/prefs_keys.dart';
import 'package:thecloud/util/global_functions.dart';
import 'package:thecloud/view/customWidgets/confirmation_dialog.dart';
import 'package:thecloud/viewModels/orders_statistics_view_model.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../viewModels/settings_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';
import '../../customWidgets/drop_down_text_field.dart';
import '../../customWidgets/main_drawer.dart';
import '../../customWidgets/no_data_widget.dart';
import '../../customWidgets/page_indicator_chip.dart';
import '../../customWidgets/server_error_widget.dart';
import 'widgets/item_statistics_list_item.dart';

class OrdersStatisticsScreen extends StatefulWidget {
  const OrdersStatisticsScreen({Key? key}) : super(key: key);
  static const routeName = '/orders_statistics_screen';

  @override
  State<OrdersStatisticsScreen> createState() => _OrdersStatisticsScreenState();
}

class _OrdersStatisticsScreenState extends State<OrdersStatisticsScreen> {
  TextEditingController startDateController =
      TextEditingController(text: getOnlyDate(DateTime.now()));
  TextEditingController endDateController =
      TextEditingController(text: getOnlyDate(DateTime.now()));
  late TextEditingController nameController;
  late AutoScrollController scrollController;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.horizontal);
    nameController = TextEditingController(text: '');
    getPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<OrdersStatisticsViewModel>(context, listen: false)
            .getOrdersStatistics());
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void getPreferences() async {
    try {
      preferences = await SharedPreferences.getInstance();
      if (preferences!.getString(PrefsKeys.menuStatStartDate)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.menuStatStartDate)! != null) {
        startDateController.text =
            preferences!.getString(PrefsKeys.menuStatStartDate).toString();
      } else {
        endDateController =
            TextEditingController(text: getOnlyDate(DateTime.now()));
      }
      if (preferences!.getString(PrefsKeys.menuStatEndDate)!.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          preferences!.getString(PrefsKeys.menuStatEndDate)! != null) {
        endDateController.text =
            preferences!.getString(PrefsKeys.menuStatEndDate).toString();
      } else {
        endDateController =
            TextEditingController(text: getOnlyDate(DateTime.now()));
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
            backgroundColor:
                isDarkMode ? MyColors.white.withOpacity(0.1) : MyColors.white,
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
                    opacity: 0.03)),
            child: Consumer<OrdersStatisticsViewModel>(
              builder: (context, statisticsViewModel, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (statisticsViewModel.numberOfPages > 1) {
                    scrollController
                        .scrollToIndex(statisticsViewModel.pageNumber - 1);
                  }
                });
                return statisticsViewModel.isLoading
                    ? const LoadingIconWidget()
                    : statisticsViewModel.isError
                        ? ServerErrorWidget(
                            onTap: () =>
                                statisticsViewModel.getOrdersStatistics(),
                          )
                        : RefreshIndicator(
                            onRefresh: () {
                              preferences!.remove(PrefsKeys.menuStatStartDate);
                              preferences!.remove(PrefsKeys.menuStatEndDate);
                              nameController.text = '';
                              startDateController.text =
                                  getOnlyDate(DateTime.now());
                              endDateController.text =
                                  getOnlyDate(DateTime.now());
                              return statisticsViewModel.getOrdersStatistics();
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
                                      width: 10,
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Text(
                                        _trans.menu_statistics,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      child: Text(_trans.export_item_history),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ConfirmationDialog(
                                                    content: _trans
                                                        .export_item_history,
                                                    confirmFunction: () {
                                                      statisticsViewModel
                                                          .exportItemHistory();
                                                    }));
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
                                Container(
                                  color: isDarkMode
                                      ? MyColors.backgroundLevel0
                                      : MyColors.grey,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            _trans.start_date,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 150,
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
                                                  statisticsViewModel
                                                      .changeStartDate(
                                                          getOnlyDate(date));
                                                  startDateController.text =
                                                      statisticsViewModel
                                                          .startDate;
                                                  preferences!.setString(
                                                      PrefsKeys
                                                          .menuStatStartDate,
                                                      startDateController.text);
                                                }
                                              },
                                            ),
                                          ),
                                          Text(
                                            _trans.end_date,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(
                                            width: 150,
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
                                                  statisticsViewModel
                                                      .changeEndDate(
                                                          getOnlyDate(date));
                                                  endDateController.text =
                                                      statisticsViewModel
                                                          .endDate;
                                                  preferences!.setString(
                                                      PrefsKeys.menuStatEndDate,
                                                      endDateController.text);
                                                }
                                              },
                                            ),
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
                                                controller: nameController,
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
                                                    hintText: _trans.name,
                                                    fillColor: Colors.white),
                                              )),
                                          const Spacer(),
                                          ElevatedButton(
                                            child: Text(_trans.search),
                                            onPressed: () {
                                              if (endDate.isBefore(startDate)) {
                                                showToast(
                                                    message: _trans
                                                        .select_valid_dates);
                                              } else {
                                                statisticsViewModel.searchName(
                                                    nameController.text);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.green),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          ElevatedButton(
                                            child: Text(_trans.clear),
                                            onPressed: () {
                                              statisticsViewModel
                                                  .getOrdersStatistics();
                                              preferences!.remove(
                                                  PrefsKeys.menuStatStartDate);
                                              preferences!.remove(
                                                  PrefsKeys.menuStatEndDate);
                                              nameController.text = '';
                                              startDateController.text =
                                                  getOnlyDate(DateTime.now());
                                              endDateController.text =
                                                  getOnlyDate(DateTime.now());
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.paleRed),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
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
                                      Text(
                                        _trans.kitchen_name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (isTablet)
                                      const SizedBox(
                                        width: 110,
                                      ),
                                    if (isTablet)
                                      Text(
                                        _trans.brand,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (isTablet)
                                      const SizedBox(
                                        width: 65,
                                      ),
                                    Text(
                                      _trans.ordered_quantity,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    Text(
                                      _trans.total_cost,
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
                                  height: 10,
                                ),
                                statisticsViewModel.ordersStatistics!.isEmpty
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 100,
                                          ),
                                          NoDataWidget(
                                            onTap: () => statisticsViewModel
                                                .getOrdersStatistics(),
                                          ),
                                        ],
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (context, index) =>
                                              Column(
                                            children: [
                                              ItemStatisticsListItem(
                                                  itemStatistics:
                                                      statisticsViewModel
                                                              .ordersStatistics![
                                                          index]),
                                              const Divider(),
                                            ],
                                          ),
                                          itemCount: statisticsViewModel
                                              .ordersStatistics!.length,
                                        ),
                                      ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (statisticsViewModel.numberOfPages > 1)
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
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 5),
                                            child: PageIndicatorChip(
                                              pageNumber:
                                                  (index + 1).toString(),
                                              isSelected: (index + 1) ==
                                                  statisticsViewModel
                                                      .pageNumber,
                                              onTap: () {
                                                statisticsViewModel
                                                    .searchPage(index + 1);
                                              },
                                            ),
                                          ),
                                        ),
                                        itemCount:
                                            statisticsViewModel.numberOfPages,
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

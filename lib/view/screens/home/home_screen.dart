import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/view/customWidgets/main_drawer.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../util/global_functions.dart';
import '../../../viewModels/home_view_model.dart';
import '../../../viewModels/settings_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';
import '../../customWidgets/no_data_widget.dart';
import '../../customWidgets/server_error_widget.dart';
import 'widgets/order_list_item.dart';
import 'widgets/orders_items_summary_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AudioPlayer? audioPlayer;
  Timer? timer;
  Timer? timerForRefreshingOrders;

  // The receive port for flutter downloader
  final ReceivePort _port = ReceivePort();

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status == DownloadTaskStatus.complete && progress == 100) {
        String _localPath =
            await findLocalPath() + Platform.pathSeparator + 'Download';
        OpenFile.open(_localPath + Platform.pathSeparator + 'The Cloud App.apk',
            type: 'application/vnd.android.package-archive');
        IsolateNameServer.removePortNameMapping('downloader_send_port');
        IsolateNameServer.registerPortWithName(
            _port.sendPort, 'downloader_send_port');
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Provider.of<HomeViewModel>(context, listen: false).getOrders());
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<HomeViewModel>(context, listen: false).getAppVersion());
    // Periodically check for orders updates
    timer = Timer.periodic(const Duration(milliseconds: 7000), (timer) {
      Provider.of<HomeViewModel>(context, listen: false).periodicCheckOrders();
    });
    timerForRefreshingOrders =
        Timer.periodic(const Duration(hours: 5), (timer) {
      Provider.of<HomeViewModel>(context, listen: false).getOrders();
    });
    audioPlayer = AudioPlayer();
    if (!kIsWeb) {
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
    }
    super.initState();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    audioPlayer!.dispose();
    timer!.cancel();
    timerForRefreshingOrders!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final _trans = AppLocalizations.of(context)!;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var width = MediaQuery.of(context).size.width;
    var brightness = Provider.of<SettingsViewModel>(context, listen: true)
        .setting
        .brightness;
    bool isDarkMode = brightness == Brightness.dark;
    audioPlayer!.stop();
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: const OrdersItemsSummaryDrawer(),
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
            actions: [
              /* Consumer<SettingsViewModel>(
                  builder: (context, settingsViewModel, child) {
                return TextButton(
                  onPressed: () {
                    bool language =
                        settingsViewModel.setting.mobileLanguage.languageCode ==
                            'en';
                    settingsViewModel.changeLanguage(language ? 'ar' : 'en');
                  },
                  child: Text(
                    settingsViewModel.setting.mobileLanguage.languageCode ==
                            'en'
                        ? 'العربية'
                        : 'English',
                    style: TextStyle(color: MyColors.green),
                  ),
                );
              }),
              Consumer<SettingsViewModel>(
                  builder: (context, settingsViewModel, child) {
                return TextButton(
                    onPressed: () {
                      settingsViewModel.changeBrightness();
                    },
                    child: Text(
                      settingsViewModel.setting.brightness == Brightness.light
                          ? _trans.dark_theme
                          : _trans.white_theme,
                      style: TextStyle(color: MyColors.green),
                    ));
              }),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                            content: _trans.are_you_sure_you_want_to_logout,
                            confirmFunction: () {
                              Provider.of<AuthViewModel>(context, listen: false)
                                  .logout();
                            }));
                  },
                  child: Text(
                    _trans.log_out,
                    style: TextStyle(color: MyColors.green),
                  )), */
              if (kIsWeb)
                Consumer<HomeViewModel>(
                    builder: (contextm, homeViewModel, child) {
                  return SizedBox(
                    width: 45.0,
                    height: 45.0,
                    child: RawMaterialButton(
                      fillColor: Colors.transparent,
                      shape: const CircleBorder(),
                      elevation: 0.0,
                      child: homeViewModel.isDownloadButtonLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: MyColors.green,
                                strokeWidth: 5,
                                backgroundColor: MyColors.white,
                              ))
                          : const Icon(
                              Icons.download_rounded,
                            ),
                      onPressed: homeViewModel.isDownloadButtonLoading
                          ? null
                          : () {
                              /* homeViewModel
                                                .launchPrintKOTToFiskoService(); */

                              // SystemSound.play(SystemSoundType.alert);
                              homeViewModel.downloadOrderInvoiceQr();
                            },
                    ),
                  );
                }),
              Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
                return Row(
                  children: [
                    Checkbox(
                        value: homeViewModel.autoPrint,
                        activeColor: MyColors.green,
                        onChanged: (value) {
                          homeViewModel.changeAutoPrintStatus();
                        }),
                    Text(_trans.auto_print),
                  ],
                );
              }),
              IconButton(
                  tooltip: _trans.orders_summary,
                  onPressed: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: Icon(
                    Icons.stacked_bar_chart_rounded,
                    color: MyColors.green,
                  )),
            ],
          ),
          //backgroundColor: MyColors.backgroundLevel1,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      Images.appIcon,
                    ),
                    // colorFilter: ColorFilter.mode(Colors.black12, BlendMode.dstATop),
                    opacity: 0.03)),
            child: Consumer<HomeViewModel>(
                builder: (context, homeViewModel, child) {

              if (homeViewModel.orders!.isNotEmpty &&
                  homeViewModel.orders!
                      .where((element) =>
                          element.newOrder! || element.updatedOrder!)
                      .isNotEmpty) {
                audioPlayer!.setReleaseMode(ReleaseMode.loop);
                audioPlayer!.play(AssetSource('audios/notification.mpeg'));
              } else {
                audioPlayer!.stop();
              }
              return homeViewModel.isLoading
                  ? const LoadingIconWidget()
                  : homeViewModel.isError
                      ? ServerErrorWidget(
                          onTap: () => homeViewModel.getOrders(),
                        )
                      : RefreshIndicator(
                          onRefresh: () => homeViewModel.getOrders(),
                          color: MyColors.green,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color: getContainerFilteredBorderColor(
                                        homeViewModel.filteredOrderStatus))),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                if (homeViewModel
                                    .filteredOrdersItemName.isNotEmpty)
                                  Text(
                                    _trans.the_orders_are_filtered_by +
                                        homeViewModel.filteredOrdersItemName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                if (homeViewModel
                                    .filteredOrdersItemName.isNotEmpty)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                DelayedDisplay(
                                  delay: const Duration(milliseconds: 200),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        child: Row(
                                          children: [
                                            // Filter orders on status
                                            // 0 for all
                                            // 1 for new
                                            // 2 for preparing
                                            // 3 for ready
                                            Radio(
                                                activeColor: MyColors.white,
                                                // fillColor: MaterialStateProperty.all(Colors.white),
                                                value: 0,
                                                groupValue: homeViewModel
                                                    .filteredOrderStatus,
                                                onChanged: (value) {
                                                  homeViewModel.filterOrders(0);
                                                }),
                                            Text(
                                              _trans.all,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: MyColors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  MyColors.newOrderColor
                                                      .withOpacity(0.6),
                                                  MyColors.newOrderColor,
                                                ],
                                              ),
                                              color: MyColors.newOrderColor),
                                          width: 75,
                                          child: Row(
                                            children: [
                                              Radio(
                                                  activeColor: MyColors.white,
                                                  value: 1,
                                                  groupValue: homeViewModel
                                                      .filteredOrderStatus,
                                                  onChanged: (value) {
                                                    homeViewModel
                                                        .filterOrders(1);
                                                  }),
                                              Text(
                                                '${homeViewModel.numberOfNewOrders}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  MyColors.preparingOrderColor
                                                      .withOpacity(0.6),
                                                  MyColors.preparingOrderColor,
                                                ],
                                              ),
                                              color:
                                                  MyColors.preparingOrderColor),
                                          width: 75,
                                          child: Row(
                                            children: [
                                              Radio(
                                                  activeColor: MyColors.white,
                                                  value: 2,
                                                  groupValue: homeViewModel
                                                      .filteredOrderStatus,
                                                  onChanged: (value) {
                                                    homeViewModel
                                                        .filterOrders(2);
                                                  }),
                                              Text(
                                                '${homeViewModel.numberOfPreparingOrders}',
                                                style: TextStyle(
                                                    color: MyColors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  MyColors.readyOrderColor
                                                      .withOpacity(0.6),
                                                  MyColors.readyOrderColor,
                                                ],
                                              ),
                                              color: MyColors.readyOrderColor),
                                          width: 75,
                                          child: Row(
                                            children: [
                                              Radio(
                                                  activeColor: MyColors.white,
                                                  focusColor: MyColors.white,
                                                  value: 3,
                                                  groupValue: homeViewModel
                                                      .filteredOrderStatus,
                                                  onChanged: (value) {
                                                    homeViewModel
                                                        .filterOrders(3);
                                                  }),
                                              Text(
                                                '${homeViewModel.numberOfReadyOrders}',
                                                style: TextStyle(
                                                    color: MyColors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                homeViewModel.orders!.isEmpty
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 100,
                                          ),
                                          NoDataWidget(
                                            content: _trans.no_current_orders,
                                            onTap: () =>
                                                homeViewModel.getOrders(),
                                          ),
                                        ],
                                      )
                                    : Expanded(
                                        child: kIsWeb
                                            ? MasonryGridView.count(
                                                crossAxisCount: width >= 900 &&
                                                        width <= 1200
                                                    ? 3
                                                    : width > 1200
                                                        ? 4
                                                        : width <= 600
                                                            ? 1
                                                            : 2,
                                                mainAxisSpacing: 4,
                                                crossAxisSpacing: 4,
                                                itemCount: homeViewModel
                                                    .orders!.length,
                                                itemBuilder: (context, index) {
                                                  return DelayedDisplay(
                                                    delay: const Duration(
                                                        milliseconds: 400),
                                                    child: OrderListItem(
                                                      order: homeViewModel
                                                          .orders![index],
                                                      expanded: homeViewModel
                                                              .orders![index]
                                                              .newOrder! ||
                                                          homeViewModel
                                                              .orders![index]
                                                              .updatedOrder!,
                                                      indexOfOrder: index,
                                                    ),
                                                  );
                                                },
                                              )
                                            : !isTablet
                                                ? isPortrait
                                                    ? ListView.builder(
                                                        itemBuilder:
                                                            (context, index) =>
                                                                DelayedDisplay(
                                                          delay: const Duration(
                                                              milliseconds:
                                                                  400),
                                                          child: OrderListItem(
                                                            order: homeViewModel
                                                                .orders![index],
                                                            expanded: homeViewModel
                                                                    .orders![
                                                                        index]
                                                                    .newOrder! ||
                                                                homeViewModel
                                                                    .orders![
                                                                        index]
                                                                    .updatedOrder!,
                                                            indexOfOrder: index,
                                                          ),
                                                        ),
                                                        itemCount: homeViewModel
                                                            .orders!.length,
                                                      )
                                                    : MasonryGridView.count(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 4,
                                                        crossAxisSpacing: 4,
                                                        itemCount: homeViewModel
                                                            .orders!.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return DelayedDisplay(
                                                            delay:
                                                                const Duration(
                                                                    milliseconds:
                                                                        400),
                                                            child:
                                                                OrderListItem(
                                                              order: homeViewModel
                                                                      .orders![
                                                                  index],
                                                              expanded: homeViewModel
                                                                      .orders![
                                                                          index]
                                                                      .newOrder! ||
                                                                  homeViewModel
                                                                      .orders![
                                                                          index]
                                                                      .updatedOrder!,
                                                              indexOfOrder:
                                                                  index,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                /* Swiper(
                          itemCount: 10,
                          itemBuilder: (context, i) =>
                                OrderListItem(order: Order()),
                          layout: SwiperLayout.STACK,
                          itemWidth: 370,
                        ) */
                                                : MasonryGridView.count(
                                                    crossAxisCount: isPortrait
                                                        ? 2
                                                        : width >= 1200
                                                            ? 4
                                                            : 3,
                                                    mainAxisSpacing: 4,
                                                    crossAxisSpacing: 4,
                                                    itemCount: homeViewModel
                                                        .orders!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return DelayedDisplay(
                                                        delay: const Duration(
                                                            milliseconds: 400),
                                                        child: OrderListItem(
                                                          order: homeViewModel
                                                              .orders![index],
                                                          expanded: homeViewModel
                                                                  .orders![
                                                                      index]
                                                                  .newOrder! ||
                                                              homeViewModel
                                                                  .orders![
                                                                      index]
                                                                  .updatedOrder!,
                                                          indexOfOrder: index,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                      )
                              ],
                            ),
                          ));
            }),
          ),
        ),
      ),
    );
  }
}

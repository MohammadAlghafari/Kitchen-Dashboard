import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/infrastructure/home/model/order_item.dart';
import 'package:thecloud/view/customWidgets/circular_loading_widget.dart';

import '../../../../common/colors.dart';
import '../../../../infrastructure/home/model/order.dart';
import '../../../../util/global_functions.dart';
import '../../../../viewModels/home_view_model.dart';
import '../../../../viewModels/settings_view_model.dart';
import '../../../customWidgets/confirmation_dialog.dart';
import '../../../customWidgets/custom_expansion_tile.dart';
import 'driver_arrived_confirmation_dialog.dart';
import 'order_cod_dialog.dart';

class OrderListItem extends StatefulWidget {
  const OrderListItem(
      {Key? key,
      required this.order,
      required this.expanded,
      required this.indexOfOrder})
      : super(key: key);
  final Order order;
  final bool expanded;
  final int indexOfOrder;

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _animationController.repeat(reverse: true));
    if (widget.order.newOrder!) {
      if (widget.order.displayUrl!.isNotEmpty) {
        Provider.of<HomeViewModel>(context, listen: false)
            .updateOrderDisplayTime(widget.order.displayUrl!);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Provider.of<SettingsViewModel>(context, listen: false)
        .setting
        .brightness;
    bool isDarkMode = brightness == Brightness.dark;
    final _trans = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: Provider.of<SettingsViewModel>(context, listen: false)
                  .setting
                  .mobileLanguage
                  .languageCode ==
              'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? MyColors.backgroundLevel0 : MyColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: CustomExpansionTile(
          initiallyExpanded: widget.expanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _trans.customer,
                            style: Theme.of(context).textTheme.bodyLarge!,
                          ),
                          Flexible(
                            child: Text(
                             widget.order.customerName.toString(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge!.merge(
                                        TextStyle(
                                          color: hexColor(widget.order.cardCss),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (widget.order.brandName != null &&
                        widget.order.brandName != '')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _trans.brand_name,
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            Flexible(
                              child: Text(
                                widget.order.brandName.toString(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .merge(TextStyle(
                                      color: hexColor(widget.order.cardCss),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    if (widget.order.brandName != null)
                      const SizedBox(
                        height: 5,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _trans.pickup_by,
                            style: Theme.of(context).textTheme.bodyLarge!,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              widget.order.pickupBy! == ''
                                  ? 'N/A'
                                  : widget.order.pickupBy!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .merge(TextStyle(
                                    color: hexColor(widget.order.cardCss),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _trans.order_time,
                            style: Theme.of(context).textTheme.bodyLarge!,
                          ),
                          Flexible(
                            child: Text(
                              widget.order.orderTime.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .merge(TextStyle(
                                    color: hexColor(widget.order.cardCss),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _trans.pickup_time,
                            style: Theme.of(context).textTheme.bodyLarge!,
                          ),
                          Flexible(
                            child: Text(
                              widget.order.pickupTime.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .merge(TextStyle(
                                    color: hexColor(widget.order.cardCss),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    /* Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        color: isDarkMode
                            ? MyColors.backgroundLevel2
                            : MyColors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_trans.customer_comments,
                                style: Theme.of(context).textTheme.bodyLarge!),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.comment,
                            )
                          ],
                        ),
                      ),
                    ), */
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? MyColors.backgroundLevel2
                                : MyColors.white,
                            shape: BoxShape.rectangle,
                            border: isDarkMode
                                ? null
                                : Border.all(width: 0.5, color: Colors.grey)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: _trans.customer_comments,
                              child: const Icon(
                                Icons.comment,
                                size: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              // width: 150,
                              child: Text(
                                  widget.order.comments!.replaceAll("\t", "t"),
                                  style:
                                  TextStyle(
                                    fontSize:
                                    kIsWeb && isTablet?
                                    12 : 11,
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /* const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        color: isDarkMode
                            ? MyColors.backgroundLevel2
                            : MyColors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_trans.order_items,
                                style: Theme.of(context).textTheme.bodyLarge!),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.restaurant,
                            ),
                          ],
                        ),
                      ),
                    ), */
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: widget.order.items!
                          .map((orderItem) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: orderItem.completed == 0
                                              ? false
                                              : true,
                                          onChanged: (itemCompletionStatus) {
                                            Provider.of<HomeViewModel>(context,
                                                    listen: false)
                                                .changeOrderItemCompletion(
                                                    orderId: widget.order.id!,
                                                    itemId: orderItem.itemId!,
                                                    itemMenuId:
                                                        orderItem.itemMenuId!,
                                                    itemDetails:
                                                        orderItem.itemsDetails!,
                                                    newValue:
                                                        itemCompletionStatus!);
                                          },
                                          activeColor: MyColors.green,
                                        ),
                                        Flexible(
                                          child: Text(orderItem.itemsDetails!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!),
                                        ),
                                      ],
                                    ),
                                    if (orderItem
                                        .addOnsWithCategory!.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(_trans.add_ons,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!),
                                          ...List.generate(
                                            orderItem
                                                .addOnsWithCategory!.length,
                                            (index) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Text(
                                                    orderItem
                                                        .addOnsWithCategory![
                                                            index]
                                                        .category,
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!,
                                                  ),
                                                ),
                                                ...List.generate(
                                                    orderItem
                                                        .addOnsWithCategory![
                                                            index]
                                                        .addOns
                                                        .length, (addOnsIndex) {
                                                  AddOn addOn = orderItem
                                                      .addOnsWithCategory![
                                                          index]
                                                      .addOns[addOnsIndex];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0),
                                                    child: addOn.name
                                                            .contains("cm")
                                                        ? Directionality(
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                            child: Text(
                                                                '${addOn.name}  x${addOn.quantity}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!),
                                                          )
                                                        : Text(
                                                            '${addOn.name}  x${addOn.quantity}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!),
                                                  );
                                                }),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    Divider(
                                      color: isDarkMode
                                          ? MyColors.white
                                          : MyColors.grey,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    /* const SizedBox(
                      height: 10,
                    ), */
                    /* Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Consumer<HomeViewModel>(
                              builder: (context, homeViewModel, child) {
                            return FloatingActionButton(
                              heroTag: null,
                              onPressed: homeViewModel.isPrintButtonLoading
                                  ? null
                                  : () {
                                      homeViewModel.printReceipt(
                                        orderId: widget.order.id!,
                                        receiptType: 'customer',
                                      );
                                    },
                              child: homeViewModel.isPrintButtonLoading
                                  ? const CircularLoadingWidget()
                                  : Icon(
                                      Icons.print_rounded,
                                      color: isDarkMode
                                          ? MyColors.white
                                          : MyColors.black,
                                    ),
                              backgroundColor: isDarkMode
                                  ? MyColors.backgroundLevel2
                                  : MyColors.grey,
                              elevation: 0.2,
                            );
                          }),
                          const SizedBox(
                            width: 15,
                          ),
                          Consumer<HomeViewModel>(
                              builder: (context, homeViewModel, child) {
                            return FloatingActionButton(
                              heroTag: null,
                              onPressed: homeViewModel.isPrintButtonLoading
                                  ? null
                                  : () {
                                      homeViewModel.printReceipt(
                                        orderId: widget.order.id!,
                                        receiptType: 'kitchen',
                                      );
                                    },
                              child: homeViewModel.isPrintButtonLoading
                                  ? const CircularLoadingWidget()
                                  : Text(
                                      'KOT',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isDarkMode
                                            ? MyColors.white
                                            : MyColors.black,
                                      ),
                                    ),
                              backgroundColor: isDarkMode
                                  ? MyColors.backgroundLevel2
                                  : MyColors.grey,
                              elevation: 0.2,
                            );
                          })
                        ],
                      ),
                    ), */
                    const SizedBox(
                      height: 10,
                    ),
                    /* const Divider(
                      height: 1,
                      thickness: 1,
                    ), */
                  ],
                ),
                if (widget.order.updatedOrder!)
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(10))),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.order.updatedOrderMessage!,
                            style:
                                TextStyle(color: MyColors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Provider.of<HomeViewModel>(context,
                                        listen: false)
                                    .changeOrderUpdated(widget.order.id);
                              },
                              child: Text(_trans.okay),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hexColor(widget.order.cardCss),
                                textStyle: const TextStyle(fontSize: 16),
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          title: widget.order.newOrder! || widget.order.updatedOrder!
              ? FadeTransition(
                  opacity: _animationController,
                  child: OrderListItemHeader(
                    order: widget.order,
                    isDarkMode: isDarkMode,
                    index: widget.indexOfOrder,
                  ))
              : OrderListItemHeader(
                  order: widget.order,
                  isDarkMode: isDarkMode,
                  index: widget.indexOfOrder,
                ),
        ),
      ),
    );
  }
}

class OrderListItemHeader extends StatefulWidget {
  const OrderListItemHeader(
      {Key? key,
      required this.order,
      required this.isDarkMode,
      required this.index})
      : super(key: key);
  final Order order;
  final bool isDarkMode;
  final int index;

  @override
  State<OrderListItemHeader> createState() => _OrderListItemHeaderState();
}

class _OrderListItemHeaderState extends State<OrderListItemHeader> {
  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexColor(widget.order.cardCss).withOpacity(0.5),
                hexColor(widget.order.cardCss),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
              color: hexColor(widget.order.cardCss),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(widget.order.status!.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6!.merge(TextStyle(
                      color: MyColors.white, fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 5,
              ),
              Text(
                widget.order.incrementId! + ' - ' + widget.order.platformName!,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle2!.merge(
                      TextStyle(
                        color: MyColors.white,
                      ),
                    ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                  widget.order.kitchenName! +
                      ' - ' +
                      widget.order.kitchenBranch!,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
                            color: MyColors.white,
                          ))),
              const SizedBox(
                height: 5,
              ),
              Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
                return Container(
                  color: widget.isDarkMode
                      ? MyColors.backgroundLevel2
                      : Colors.grey[200],
                  width: double.infinity,
                  height: 55,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              if (widget.order.codAmount!) {
                                showDialog(
                                    context: context,
                                    builder: (context) => OrderCodDialog(
                                          orderId: widget.order.id!,
                                          status: widget.order.status!,
                                        ),
                                );
                              } else {
                                if (widget.order.statusId == 3) {
                                  if (homeViewModel
                                      .counterForDisablingStatusButton >
                                      0 &&
                                      widget.index == homeViewModel.indexForOrderStatus) {}else {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ConfirmationDialog(
                                            content: _trans
                                                .are_you_sure_you_want_to_change_order_status,
                                            confirmFunction: () {
                                              homeViewModel
                                                  .indexGetting(widget.index);
                                              homeViewModel.updateOrderStatus(
                                                  orderId: widget.order.id!,
                                                  orderStatus:
                                                  widget.order.status!);
                                              if (homeViewModel.autoPrint) {
                                                if (widget.order.statusId ==
                                                    1) {
                                                  homeViewModel.printReceipt(
                                                      orderId: widget.order.id!,
                                                      receiptType: 'kitchen');
                                                }
                                              }
                                              if (homeViewModel.autoPrint) {
                                                if (widget.order.statusId ==
                                                    2) {
                                                  homeViewModel.printReceipt(
                                                      orderId: widget.order.id!,
                                                      receiptType: 'customer');
                                                }
                                              }
                                            },
                                          ),
                                    );
                                  }
                                }
                                else {
                                  // ("timer odf: ${homeViewModel.timer}");
                                  // homeViewModel.startTimer();
                                  homeViewModel
                                      .indexGetting(widget.index);
                                  if (homeViewModel
                                      .counterForDisablingStatusButton >
                                      0 &&
                                      widget.index == homeViewModel.indexForOrderStatus) {} else {
                                    homeViewModel.updateOrderStatus(
                                        orderId: widget.order.id!,
                                        orderStatus:
                                        widget.order.status!);
                                    if (homeViewModel.autoPrint) {
                                      if (widget.order.statusId == 1) {
                                        homeViewModel.printReceipt(
                                            orderId: widget.order.id!,
                                            receiptType: 'kitchen');
                                      }
                                    }
                                    if (homeViewModel.autoPrint) {
                                      if (widget.order.statusId == 2) {
                                        homeViewModel.printReceipt(
                                            orderId: widget.order.id!,
                                            receiptType: 'customer');
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            child: homeViewModel.isUpdateButtonLoading &&
                                    widget.index == homeViewModel.indexForOrderStatus
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxHeight: 50, maxWidth: 75,
                                    ),
                                    child: CircularLoadingWidget(progressColor: widget.order.cardCss,),
                            )
                                : Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      widget.order.buttonMessage!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14, color: MyColors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                backgroundColor: /* isDarkMode
                                             ? MyColors.backgroundLevel0
                                             : */
                                homeViewModel.counterForDisablingStatusButton > 0&&
                                    widget.index == homeViewModel.indexForOrderStatus?
                                    Colors.transparent:
                                    hexColor(widget.order.cardCss),
                                maximumSize: const Size(200, 50))),
                        if (widget.order.statusId != 1)
                          SizedBox(
                            width: 45.0,
                            height: 45.0,
                            child: RawMaterialButton(
                              fillColor: Colors.transparent,
                              shape: const CircleBorder(),
                              elevation: 0.0,
                              child: homeViewModel.isDeliveryGuyButtonLoading
                                  ? const CircularLoadingWidget()
                                  : Icon(
                                      Icons.motorcycle_outlined,
                                      color: widget.isDarkMode
                                          ? MyColors.white
                                          : MyColors.black,
                                    ),
                              onPressed: homeViewModel
                                      .isDeliveryGuyButtonLoading
                                  ? null
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              DriverArrivedConfirmationDialog(
                                                  driverName:
                                                      widget.order.riderName!,
                                                  driverPhone:
                                                      widget.order.riderPhone!,
                                                  estimatedDistance: widget
                                                      .order.estimatedDistance!,
                                                  estimatedDuration: widget
                                                      .order
                                                      .estimstedDriverDuration!,
                                                  buttonEnabled: widget
                                                      .order.riderButtonActive!,
                                                  samePlatform: widget
                                                      .order.samePlatform!,
                                                  confirmFunction: () {
                                                    homeViewModel
                                                        .deliveryGuyArrived(
                                                            orderId: widget
                                                                .order.id!);
                                                  }));
                                    },
                            ),
                          ),
                        /* TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => ConfirmationDialog(
                                        content: _trans
                                            .are_you_sure_the_driver_has_arrived,
                                        confirmFunction: () {
                                          homeViewModel.deliveryGuyArrived(
                                              orderId: order.id!);
                                        }));
                              },
                              child: homeViewModel.isdeliveryGuyButtonLoading
                                  ? ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxHeight: 50, maxWidth: 75),
                                      child: const CircularLoadingWidget())
                                  : Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        _trans.rider,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode
                                                ? MyColors.black
                                                : MyColors.white),
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  primary: isDarkMode
                                      ? MyColors.white
                                      : MyColors.deliveryButtonColor,
                                  maximumSize: const Size(200, 50))), */
                        SizedBox(
                          width: 45.0,
                          height: 45.0,
                          child: RawMaterialButton(
                            fillColor: Colors.transparent,
                            shape: const CircleBorder(),
                            // hoverColor: kIsWeb ? Colors.grey : Colors.yellow,
                            // highlightColor:
                            //     kIsWeb ? Colors.grey : Colors.yellow,
                            // splashColor: Colors.red,
                            hoverElevation: 20.0,
                            elevation: 0.0,
                            child: homeViewModel.isPrintKotButtonLoading &&
                                    widget.index ==
                                        homeViewModel.indexForOrderStatus
                                ? CircularLoadingWidget(progressColor: widget.order.cardCss,)
                                :
                                // widget.order.id! == orderIndex
                                //         &&
                                //     homeViewModel.isPrintKotButtonLoading
                                // &&
                                //     isLoading == true
                                // widget.index.containsValue(widget.order.id)
                                // widget.index.values.first == orderIndex.toString()
                                // // orderIndex == int.parse(widget.index.values.first)
                                //                                     ? const CircularLoadingWidget()
                                //                                     :
                                Text(
                                    'KOT',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDarkMode
                                            ? MyColors.white
                                            : MyColors.black),
                                  ),
                            onPressed: homeViewModel
                                    .isPrintCustomerButtonLoading
                                // order.id == orderIndex
                                ? null
                                : () {
                                    // print("index 2: $orderIndex");
                                    // print("index 3: ${orderIndex == int.parse(widget.index.values.first)}");
                                    /* homeViewModel
                                            .luanchPrintKOTToFiskoService(); */
                                    // setState(() {
                                    //   isLoading = true;
                                    //   orderIndex = int.parse(widget.index.values.first);
                                    // });
                                    // // widget.order.id! == this.widget.order.id;
                                    // // Duration(seconds: 4);
                                    // print("Order Index1: ${widget.order.id}");
                                    // print(
                                    //     "Order Index2: ${widget.index}");
                                    // // if (orderIndex == int.parse(widget.index.values.first)) {
                                    //   print("A condition");
                                    homeViewModel.indexGetting(widget.index);
                                    homeViewModel.printReceipt(
                                        orderId: widget.order.id!,
                                        receiptType: 'kitchen',
                                        isEqual: true);
                                    // } else {
                                    //   print("else");
                                    //   homeViewModel.printReceipt(
                                    //       orderId: widget.order.id!,
                                    //       receiptType: 'kitchen',
                                    //       isEqual: false);
                                    // }
                                  },
                          ),
                        ),
                        if (widget.order.statusId == 3)
                          SizedBox(
                            width: 45.0,
                            height: 45.0,
                            child: RawMaterialButton(
                              fillColor: Colors.transparent,
                              shape: const CircleBorder(),
                              // hoverColor: kIsWeb ? Colors.grey : Colors.yellow,
                              // highlightColor:
                              //     kIsWeb ? Colors.grey : Colors.yellow,
                              splashColor: Colors.red,
                              elevation: 0.0,
                              child:
                                  homeViewModel.isPrintCustomerButtonLoading &&
                                          widget.index ==
                                              homeViewModel.indexForOrderStatus
                                      ? CircularLoadingWidget(progressColor: widget.order.cardCss)
                                      : Icon(
                                          Icons.print_rounded,
                                          color: widget.isDarkMode
                                              ? MyColors.white
                                              : MyColors.black,
                                        ),
                              onPressed: homeViewModel.isPrintKotButtonLoading
                                  ? null
                                  : () {
                                      if (widget
                                          .order.customerAlreadyprinted!) {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ConfirmationDialog(
                                                    content: _trans
                                                        .customer_receipet_already_printed,
                                                    confirmFunction: () {
                                                      homeViewModel
                                                          .indexGetting(
                                                              widget.index);
                                                      homeViewModel
                                                          .printReceipt(
                                                        orderId:
                                                            widget.order.id!,
                                                        receiptType: 'customer',
                                                      );
                                                    }));
                                      }
                                      /* homeViewModel
                                        .luanchPrintCustomerToFiskoService(); */
                                      else {
                                        homeViewModel.printReceipt(
                                          orderId: widget.order.id!,
                                          receiptType: 'customer',
                                        );
                                      }
                                    },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        /* Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
          return Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                width: 45.0,
                height: 45.0,
                child: RawMaterialButton(
                  fillColor: Colors.transparent,
                  shape: const CircleBorder(),
                  elevation: 0.0,
                  child: homeViewModel.isPrintButtonLoading
                      ? const CircularLoadingWidget()
                      : Icon(
                          Icons.print,
                          color: isDarkMode ? MyColors.white : MyColors.black,
                        ),
                  onPressed: homeViewModel.isPrintButtonLoading
                      ? null
                      : () {
                          homeViewModel.printReceipt(
                            orderId: order.id!,
                            receiptType: 'customer',
                          );
                        },
                ),
              ));
        }),
        Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
          return Positioned(
              bottom: 0,
              right: 50,
              child: SizedBox(
                width: 45.0,
                height: 45.0,
                child: RawMaterialButton(
                  fillColor: Colors.transparent,
                  shape: const CircleBorder(),
                  elevation: 0.0,
                  child: homeViewModel.isPrintButtonLoading
                      ? const CircularLoadingWidget()
                      : Text(
                          'KOT',
                          style: TextStyle(
                              color:
                                  isDarkMode ? MyColors.white : MyColors.black),
                        ),
                  onPressed: homeViewModel.isPrintButtonLoading
                      ? null
                      : () {
                          homeViewModel.printReceipt(
                            orderId: order.id!,
                            receiptType: 'kitchen',
                          );
                        },
                ),
              ));
        }), */
      ],
    );
  }
}

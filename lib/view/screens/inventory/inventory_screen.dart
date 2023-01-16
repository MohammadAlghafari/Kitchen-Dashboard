import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:thecloud/infrastructure/inventory/model/kitchen_model.dart';
import 'package:thecloud/util/global_functions.dart';
import 'package:thecloud/view/customWidgets/creation_aware_list_item.dart';
import 'package:thecloud/view/screens/inventory/widgets/inventory_item_list_item.dart';
import 'package:thecloud/viewModels/inventory_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../util/navigation_service.dart';
import '../../../viewModels/settings_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';
import '../../customWidgets/main_drawer.dart';
import '../../customWidgets/no_data_widget.dart';
import '../../customWidgets/server_error_widget.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);
  static const routeName = '/inventory_screen';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String availabilityType = AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!.all;
  String itemName = '';
  KitchenModel kitchen = KitchenModel(
      kitchenId: '-1',
      kitchenName:
          AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!
              .all,
      kitchenBranch: '');



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<InventoryViewModel>(context, listen: false)
            .getInventoryItems());
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
          body:
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          Images.appIcon,
                        ),
                        // colorFilter: ColorFilter.mode(Colors.black12, BlendMode.dstATop),
                        opacity: 0.03)),
                child: Consumer<InventoryViewModel>(
                  builder: (context, inventoryViewModel, child) {
                    return inventoryViewModel.isLoading
                        ? const LoadingIconWidget()
                        : inventoryViewModel.isError
                        ? ServerErrorWidget(
                      onTap: () => inventoryViewModel.getInventoryItems(),
                    )
                        : RefreshIndicator(
                      onRefresh: () =>
                          inventoryViewModel.getInventoryItems(),
                      color: MyColors.green,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      child: ElevatedButton(
                                        child: Text(_trans.clear),
                                        onPressed: () {
                                          inventoryViewModel
                                              .getInventoryItems();
                                          inventoryViewModel
                                              .searchAvailability(
                                              _trans.all);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            MyColors.paleRed),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width: 130,
                                        height: 40,
                                        child: TextField(
                                          maxLines: 1,
                                          onChanged: (name) {
                                            itemName = name;
                                            // inventoryViewModel.combinedSearch(itemName, kitchen, availabilityType);
                                          },
                                          onSubmitted: (name) {
                                            // inventoryViewModel.searchName(name);
                                            itemName = name;
                                          },
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
                                    // const SizedBox(height: 10,),
                                    /* SizedBox(
                                                width: 120,
                                                height: 40,
                                                child: TextField(
                                                  maxLines: 1,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  onChanged: (price) {
                                                    inventoryViewModel
                                                        .searchPrice(price);
                                                  },
                                                  cursorColor: MyColors.green,
                                                  style:
                                                      TextStyle(color: MyColors.black),
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(10),
                                                          borderSide: BorderSide.none),
                                                      hintText: _trans.price,
                                                      fillColor: Colors.white),
                                                )), */

                                    SizedBox(
                                      width: 110,
                                      child: DropdownButton(
                                        value: inventoryViewModel
                                            .searchedAvailability,
                                        items: [
                                          _trans.all,
                                          _trans.available,
                                          _trans.unavailable
                                        ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                        underline: Container(
                                          height: 1.0,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 1.0))),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        onChanged: (selected) {
                                          availabilityType =
                                              selected.toString();
                                          inventoryViewModel
                                              .settingStateForAvailability(
                                              availabilityType);
                                        },
                                        isExpanded: true,
                                      ),
                                    ),
                                    ElevatedButton(
                                      child: Text(_trans.search),
                                      onPressed: () {
                                        inventoryViewModel.combinedSearch(
                                            itemName,
                                            kitchen,
                                            availabilityType);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          MyColors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: DropdownButton(
                              value: inventoryViewModel.searchedKitchen,
                              items: inventoryViewModel.kitchens
                                  .map<DropdownMenuItem<KitchenModel>>(
                                      (KitchenModel value) {
                                    return DropdownMenuItem<KitchenModel>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                              underline: Container(
                                height: 1.0,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(width: 1.0))),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                              ),
                              onChanged: (selected) {
                                kitchen = selected as KitchenModel;
                                inventoryViewModel
                                    .settingStateFroKitchen(kitchen);
                                // inventoryViewModel.searchKitchenName(
                                //     selected as KitchenModel);
                              },
                              isExpanded: true,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: Text(
                                    _trans.item_name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                              if (kIsWeb)
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      _trans.category,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                              if (kIsWeb)
                                const SizedBox(
                                  width: 150,
                                ),
                              const SizedBox(
                                width: 00,
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: Text(
                                    _trans.branch,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                              if (isTablet)
                                const SizedBox(
                                  width: 210,
                                ),
                              // if(kIsWeb)
                              //   const SizedBox(
                              //     width: 210,
                              //   ),
                              if (isTablet)
                                Text(
                                  _trans.details,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              const Spacer(),
                              Text(
                                _trans.availability,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                          inventoryViewModel.inventoryItems!.isEmpty
                              ? Column(
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              NoDataWidget(
                                onTap: () => inventoryViewModel
                                    .getInventoryItems(),
                              ),
                            ],
                          )
                              : Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, index) => index >=
                                  inventoryViewModel
                                      .inventoryItems!
                                      .length &&
                                  inventoryViewModel
                                      .searchedName
                                      .isEmpty /* &&
                                                    inventoryViewModel
                                                        .searchedPrice.isEmpty */
                                  &&
                                  inventoryViewModel
                                      .searchedAvailability ==
                                      _trans.available
                                  ? const LoadingIconWidget()
                                  : CreationAwareListItem(
                                itemCreated: () {
                                  /* if (index ==
                                                          inventoryViewModel
                                                                  .inventoryItems!
                                                                  .length -
                                                              1) {
                                                        Provider.of<InventoryViewModel>(
                                                                context,
                                                                listen: false)
                                                            .getInventoryItemsPagination();
                                                      } */
                                },
                                child: Column(
                                  children: [
                                  index == 0?  ShowCaseWidget(
                                    builder: Builder(builder: (context){
                                      return InventoryItemListItem(
                                        inventoryViewModel: inventoryViewModel,
                                        inventoryItem: inventoryViewModel.inventoryItems![index],
                                        index: index,
                                      );
                              },
                              )
                                      // child:
                                    ): InventoryItemListItem(
                            inventoryViewModel: inventoryViewModel,
                            inventoryItem: inventoryViewModel.inventoryItems![index],
                            index: index,
                          ),
                                    const Divider(),
                                  ],
                                ),
                              ),
                              itemCount: /* inventoryViewModel
                                                        .hasReachedMax ||
                                                    inventoryViewModel.searchedhName
                                                        .isNotEmpty /* ||
                                                    inventoryViewModel
                                                        .searchedPrice.isNotEmpty */
                                                    ||
                                                    inventoryViewModel
                                                            .searchedavailability !=
                                                        _trans.available
                                                ? */
                              inventoryViewModel
                                  .inventoryItems!.length,
                              /*  : inventoryViewModel
                                                        .inventoryItems!.length +
                                                    1 */
                            ),
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

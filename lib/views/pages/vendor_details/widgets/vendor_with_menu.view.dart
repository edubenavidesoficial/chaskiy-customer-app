import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/vendor_menu_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:chaskiy/widgets/bottomsheets/cart.bottomsheet.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/custom_rounded_leading.dart';
import 'package:chaskiy/widgets/buttons/share.btn.dart';
import 'package:chaskiy/widgets/cart_page_action.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/list_items/vendor_menu_product.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorDetailsWithMenuPage extends StatefulWidget {
  VendorDetailsWithMenuPage({required this.vendor, Key? key}) : super(key: key);

  final Vendor vendor;

  @override
  _VendorDetailsWithMenuPageState createState() =>
      _VendorDetailsWithMenuPageState();
}

class _VendorDetailsWithMenuPageState extends State<VendorDetailsWithMenuPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorDetailsWithMenuViewModel>.reactive(
      viewModelBuilder:
          () => VendorDetailsWithMenuViewModel(
            context,
            widget.vendor,
            tickerProvider: this,
          ),
      onViewModelReady: (model) {
        model.tabBarController = TabController(
          length: model.vendor?.menus.length ?? 0,
          vsync: this,
        );
        model.getVendorDetails();
      },
      builder: (context, model, child) {
        final colors = Theme.of(context).colorScheme;
        final featureImageHeight = (context.percentHeight * 24).clamp(
          210.0,
          280.0,
        );
        //
        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          // floatingActionButton: UploadPrescriptionFab(model),
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: featureImageHeight,
                  floating: false,
                  pinned: true,
                  leading: CustomRoundedLeading(),
                  backgroundColor: colors.surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: FittedBox(child: ShareButton(model: model)),
                    ),
                    UiSpacer.hSpace(10),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: PageCartAction(),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(
                          imageUrl: model.vendor!.featureImage,
                          height: featureImageHeight,
                          canZoom: true,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Color(0x33000000),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: VendorDetailsHeader(
                    model,
                    showFeatureImage: false,
                    featureImageHeight: featureImageHeight,
                    showPrescription: true,
                  ),
                ),
                SliverAppBar(
                  backgroundColor: colors.surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  toolbarHeight: 62,
                  floating: false,
                  pinned: true,
                  snap: false,
                  primary: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: TabBar(
                        padding: const EdgeInsets.all(4),
                        isScrollable: true,
                        labelColor: colors.onPrimaryContainer,
                        unselectedLabelColor: colors.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                        indicator: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        controller: model.tabBarController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabAlignment: TabAlignment.start,
                        dividerHeight: 0,
                        tabs:
                            model.vendor!.menus
                                .map(
                                  (menu) => Tab(
                                    text: menu.id == 0 ? 'Todos' : menu.name,
                                    iconMargin: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: ColoredBox(
              color: colors.surfaceContainerLowest,
              child:
                  model.isBusy
                      ? BusyIndicator().p20().centered()
                      : TabBarView(
                        controller: model.tabBarController,
                        children:
                            model.vendor!.menus.map((menu) {
                              final mProducts =
                                  model.menuProducts[menu.id] ?? [];
                              //
                              return CustomEasyRefreshView(
                                // headerView: MaterialHeader(),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                onRefresh:
                                    () => model.loadMoreProducts(menu.id),
                                onLoad:
                                    () => model.loadMoreProducts(
                                      menu.id,
                                      initialLoad: false,
                                    ),
                                loading: model.busy(menu.id),
                                dataset: mProducts,
                                separator: 5.heightBox,
                                listView:
                                    mProducts.map((product) {
                                      return VendorMenuProductListItem(
                                        product,
                                        onPressed: model.productSelected,
                                        qtyUpdated: model.addToCartDirectly,
                                      );
                                    }).toList(),
                              );
                              /*
                          return CustomListView(
                            noScrollPhysics: true,
                            refreshController:
                                model.getRefreshController(menu.id),
                            canPullUp: true,
                            canRefresh: true,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            dataSet: model.menuProducts[menu.id] ?? [],
                            isLoading: model.busy(menu.id),
                            onLoading: () => model.loadMoreProducts(
                              menu.id,
                              initialLoad: false,
                            ),
                            onRefresh: () => model.loadMoreProducts(menu.id),
                            itemBuilder: (context, index) {
                              //
                              final product =
                                  model.menuProducts[menu.id]?[index];
                              return VendorMenuProductListItem(
                                product,
                                onPressed: model.productSelected,
                                qtyUpdated: model.addToCartDirectly,
                              );
                            },
                            separatorBuilder: (context, index) => 5.heightBox,
                          );
                          */
                            }).toList(),
                      ),
            ),
          ),
          bottomSheet: CartViewBottomSheet(),
        );
      },
    );
  }
}

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
      onViewModelReady: (model) => model.getVendorDetails(),
      builder: (context, model, child) {
        final colors = Theme.of(context).colorScheme;
        final featureImageHeight = (context.percentHeight * 22).clamp(
          190.0,
          245.0,
        );
        final menus = model.vendor?.menus ?? [];
        final tabsReady =
            model.tabBarController != null &&
            model.tabBarController!.length == menus.length &&
            menus.isNotEmpty;
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
                if (tabsReady)
                  SliverAppBar(
                    backgroundColor: colors.surfaceContainerLowest,
                    surfaceTintColor: Colors.transparent,
                    toolbarHeight: 54,
                    floating: false,
                    pinned: true,
                    snap: false,
                    primary: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          padding: const EdgeInsets.all(3),
                          isScrollable: true,
                          unselectedLabelColor: colors.onSurfaceVariant,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                          indicator: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          labelColor: colors.onPrimary,
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
                      : model.hasError
                      ? _VendorLoadState(
                        icon: Icons.cloud_off_rounded,
                        title: 'No pudimos cargar este proveedor',
                        message: 'Revisa tu conexión e inténtalo nuevamente.',
                        actionLabel: 'Reintentar',
                        onAction: model.getVendorDetails,
                      )
                      : !tabsReady
                      ? const _VendorLoadState(
                        icon: Icons.storefront_outlined,
                        title: 'Este proveedor aún no tiene productos',
                        message: 'Vuelve pronto para descubrir sus novedades.',
                      )
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
                                emptyView: _VendorLoadState(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'No hay productos disponibles',
                                  message:
                                      'Desliza hacia abajo para actualizar.',
                                  actionLabel: 'Actualizar',
                                  onAction:
                                      () => model.loadMoreProducts(menu.id),
                                ),
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

class _VendorLoadState extends StatelessWidget {
  const _VendorLoadState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 46, 32, 120),
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.primary, size: 28),
        ).centered(),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(actionLabel!),
          ).centered(),
        ],
      ],
    );
  }
}

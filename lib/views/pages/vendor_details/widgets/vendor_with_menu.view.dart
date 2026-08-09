import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/menu.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/vendor_menu_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/bottomsheets/vendor_full_profie.bottomsheet.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/upload_prescription.btn.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_hero.view.dart';
import 'package:chaskiy/widgets/bottomsheets/cart.bottomsheet.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/circle_action_button.dart';
import 'package:chaskiy/widgets/buttons/share.btn.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:chaskiy/widgets/inputs/search_bar.input.dart';
import 'package:chaskiy/widgets/list_items/vendor_menu_product.list_item.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';
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
        final heroHeight = (context.percentHeight * 30).clamp(240.0, 320.0);
        final menus = model.vendor?.menus ?? [];
        final tabsReady =
            model.tabBarController != null &&
            model.tabBarController!.length == menus.length &&
            menus.isNotEmpty;
        //
        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: heroHeight,
                  pinned: true,
                  backgroundColor: colors.surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  titleSpacing: 16,
                  //los botones van sobre la foto, así que llevan su propio
                  //fondo translúcido en vez de depender del color de la barra
                  title: Row(
                    children: [
                      CircleActionButton(
                        icon:
                            !Utils.isArabic
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                        iconSize: 18,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Spacer(),
                      CircleActionButton(
                        child: FavVendorTag(
                          model.vendor!,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ShareButton(
                        model: model,
                        child: const CircleActionButton(
                          icon: Icons.ios_share_rounded,
                        ),
                      ),
                      if (AppUISettings.showCart) ...[
                        const SizedBox(width: 10),
                        const CartCircleAction(),
                      ],
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: VendorHeroView(model, height: heroHeight),
                  ),
                ),

                SliverToBoxAdapter(
                  child: DecoratedBox(
                    //la portada termina en oscuro; este degradado la funde con
                    //el fondo de la página en vez de cortarla en seco
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _heroFadeColor(colors),
                          colors.surfaceContainerLowest,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchBarInput(
                              hintText: 'Buscar en ${model.vendor!.name}',
                              onTap: model.openVendorSearch,
                              showFilter: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _InfoButton(vendor: model.vendor!),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: UploadPrescriptionFab(model)),

                if (tabsReady)
                  SliverAppBar(
                    backgroundColor: colors.surfaceContainerLowest,
                    surfaceTintColor: Colors.transparent,
                    toolbarHeight: 56,
                    pinned: true,
                    primary: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: _MenuChips(
                      controller: model.tabBarController!,
                      menus: model.vendor!.menus,
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
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  bottom: 110,
                                ),
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
                                listView:
                                    mProducts.map((product) {
                                      return VendorMenuProductListItem(
                                        product,
                                        onPressed: model.productSelected,
                                        qtyUpdated: model.addToCartDirectly,
                                      );
                                    }).toList(),
                              );
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

/// Arranque del degradado bajo la portada: el fondo de la página con un velo
/// del color de marca, para que el corte de la foto no se note.
Color _heroFadeColor(ColorScheme colors) => Color.alphaBlend(
  colors.primary.withValues(alpha: .09),
  colors.surfaceContainerLowest,
);

/// Abre la ficha completa de la tienda: horarios, entrega, retiro y tiempos.
class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => VendorFullProfileBottomSheet(vendor),
            ),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            HugeIcons.strokeRoundedInformationCircle,
            size: 22,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

/// Categorías del menú como pastillas.
///
/// Sustituye al `TabBar` enmarcado, pero sigue manejando el mismo
/// `TabController`: el contenido se mueve igual y se puede seguir deslizando
/// entre categorías.
class _MenuChips extends StatelessWidget {
  const _MenuChips({required this.controller, required this.menus});

  final TabController controller;
  final List<Menu> menus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller.animation ?? controller,
      builder: (context, _) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemCount: menus.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = controller.index == index;
            final menu = menus[index];

            return Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color:
                        selected
                            ? colors.primary
                            : colors.outlineVariant.withValues(alpha: .7),
                  ),
                ),
                child: Text(
                  menu.id == 0 ? 'Todos' : menu.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ).onInkTap(() => controller.animateTo(index)),
            );
          },
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
          child: Icon(icon, color: colors.onPrimaryContainer, size: 28),
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

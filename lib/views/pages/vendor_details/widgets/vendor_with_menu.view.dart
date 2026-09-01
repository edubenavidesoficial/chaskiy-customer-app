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
import 'package:chaskiy/widgets/custom_image.view.dart';
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
  bool _showGrid = false;

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
        final heroHeight = (context.percentHeight * 22).clamp(170.0, 210.0);
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
                    background: VendorHeroView(
                      model,
                      height: heroHeight,
                      showDetails: false,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _VendorSummaryCard(vendor: model.vendor!),
                    ),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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

                if (tabsReady)
                  SliverToBoxAdapter(
                    child: _LayoutSelector(
                      showGrid: _showGrid,
                      onChanged: (value) => setState(() => _showGrid = value),
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
                              if (mProducts.isEmpty && !model.busy(menu.id)) {
                                return _VendorLoadState(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'No hay productos disponibles',
                                  message:
                                      'Desliza hacia abajo para actualizar.',
                                  actionLabel: 'Actualizar',
                                  onAction:
                                      () => model.loadMoreProducts(menu.id),
                                );
                              }

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
                                child:
                                    _showGrid
                                        ? GridView.builder(
                                          key: const PageStorageKey(
                                            'vendor-products-grid',
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            6,
                                            16,
                                            110,
                                          ),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                mainAxisExtent: 266,
                                              ),
                                          itemCount: mProducts.length,
                                          itemBuilder: (context, index) {
                                            final product = mProducts[index];
                                            return VendorMenuProductGridItem(
                                              product,
                                              onPressed: model.productSelected,
                                              qtyUpdated:
                                                  model.addToCartDirectly,
                                            );
                                          },
                                        )
                                        : ListView.builder(
                                          key: const PageStorageKey(
                                            'vendor-products-list',
                                          ),
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                            bottom: 110,
                                          ),
                                          itemCount: mProducts.length,
                                          itemBuilder: (context, index) {
                                            final product = mProducts[index];
                                            return VendorMenuProductListItem(
                                              product,
                                              onPressed: model.productSelected,
                                              qtyUpdated:
                                                  model.addToCartDirectly,
                                            );
                                          },
                                        ),
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

class _VendorSummaryCard extends StatelessWidget {
  const _VendorSummaryCard({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final deliveryTime = vendor.deliveryTime?.trim() ?? '';
    final deliveryUnit = vendor.deliveryTimeUnit?.trim() ?? '';
    final delivery = [
      deliveryTime,
      deliveryUnit,
    ].where((value) => value.isNotEmpty).join(' ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                if (AppUISettings.showVendorAddress &&
                    vendor.address.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vendor.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 19,
                      color: Color(0xFFFFB000),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vendor.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${vendor.reviews_count} reseñas)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (vendor.isOpen ? Colors.green : colors.error)
                        .withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: (vendor.isOpen ? Colors.green : colors.error)
                          .withValues(alpha: .22),
                    ),
                  ),
                  child: Text(
                    '${vendor.isOpen ? '●  Abierto' : '●  Cerrado'}${delivery.isEmpty ? '' : ' · Entrega $delivery'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          vendor.isOpen ? Colors.green.shade700 : colors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomImage(
              imageUrl: vendor.logo,
              width: 82,
              height: 82,
              boxFit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutSelector extends StatelessWidget {
  const _LayoutSelector({required this.showGrid, required this.onChanged});

  final bool showGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _LayoutOption(
            icon: Icons.format_list_bulleted_rounded,
            label: 'Lista',
            selected: !showGrid,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _LayoutOption(
            icon: Icons.grid_view_rounded,
            label: 'Cuadrícula',
            selected: showGrid,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  const _LayoutOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  selected
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: .65),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? colors.primary : null),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
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

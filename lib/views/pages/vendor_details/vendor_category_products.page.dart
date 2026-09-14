import 'package:flutter/material.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/vendor_category_products.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:chaskiy/widgets/list_items/vendor_menu_product.list_item.dart';
import 'package:stacked/stacked.dart';

class VendorCategoryProductsPage extends StatefulWidget {
  VendorCategoryProductsPage({
    required this.category,
    required this.vendor,
    Key? key,
  }) : super(key: key);

  final Category category;
  final Vendor vendor;

  @override
  _VendorCategoryProductsPageState createState() =>
      _VendorCategoryProductsPageState();
}

class _VendorCategoryProductsPageState extends State<VendorCategoryProductsPage>
    with TickerProviderStateMixin {
  //
  late TabController tabBarController;
  bool _showGrid = false;

  @override
  void initState() {
    super.initState();
    if (widget.category.subcategories.isEmpty) {
      widget.category.subcategories.add(
        Category(id: 0, name: 'Todos', imageUrl: '', photo: ''),
      );
    }
    tabBarController = TabController(
      length: widget.category.subcategories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorCategoryProductsViewModel>.reactive(
      viewModelBuilder:
          () => VendorCategoryProductsViewModel(
            context,
            widget.category,
            widget.vendor,
          ),
      onViewModelReady: (vm) => vm.initialise(),
      //
      builder: (context, model, child) {
        return BasePage(
          title: model.category.name,
          showAppBar: true,
          showLeadingAction: true,
          showCart: true,
          body: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverAppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  toolbarHeight: 58,
                  floating: true,
                  pinned: true,
                  snap: true,
                  primary: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                    indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                    controller: tabBarController,
                    tabs:
                        model.category.subcategories.map((subcategory) {
                          return Tab(text: subcategory.name);
                        }).toList(),
                  ),
                ),
              ];
            },
            body: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: Column(
                children: [
                  _CategoryLayoutSelector(
                    showGrid: _showGrid,
                    onChanged: (value) => setState(() => _showGrid = value),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabBarController,
                      children:
                          model.category.subcategories.map((subcategory) {
                            final products =
                                model.categoriesProducts[subcategory.id] ?? [];
                            if (products.isEmpty &&
                                !model.busy(subcategory.id)) {
                              return const _EmptyCategoryProducts();
                            }
                            return CustomEasyRefreshView(
                              onRefresh:
                                  () => model.loadMoreProducts(subcategory.id),
                              onLoad:
                                  () => model.loadMoreProducts(
                                    subcategory.id,
                                    initialLoad: false,
                                  ),
                              loading: model.busy(subcategory.id),
                              dataset: products,
                              child:
                                  _showGrid
                                      ? GridView.builder(
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
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          return VendorMenuProductGridItem(
                                            product,
                                            onPressed: model.productSelected,
                                            qtyUpdated: model.addToCartDirectly,
                                          );
                                        },
                                      )
                                      : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 110,
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          return VendorMenuProductListItem(
                                            product,
                                            onPressed: model.productSelected,
                                            qtyUpdated: model.addToCartDirectly,
                                          );
                                        },
                                      ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryLayoutSelector extends StatelessWidget {
  const _CategoryLayoutSelector({
    required this.showGrid,
    required this.onChanged,
  });

  final bool showGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _CategoryLayoutOption(
            icon: Icons.format_list_bulleted_rounded,
            label: 'Lista',
            selected: !showGrid,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _CategoryLayoutOption(
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

class _CategoryLayoutOption extends StatelessWidget {
  const _CategoryLayoutOption({
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
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? colors.primary : colors.onSurfaceVariant,
        backgroundColor:
            selected ? colors.primaryContainer : colors.surfaceContainerLow,
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _EmptyCategoryProducts extends StatelessWidget {
  const _EmptyCategoryProducts();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 44, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'No hay productos disponibles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

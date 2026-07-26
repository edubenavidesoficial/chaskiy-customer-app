import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_sizes.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/vendor_category_products.page.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_grid_view.dart';
import 'package:chaskiy/widgets/list_items/category.list_item.dart';
import 'package:flutter/material.dart';

class VendorDetailsWithSubcategoryPage extends StatelessWidget {
  const VendorDetailsWithSubcategoryPage({required this.model, super.key});

  final VendorDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    final vendor = model.vendor!;
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: RefreshIndicator(
        onRefresh: () async => model.getVendorDetails(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            VendorDetailsHeader(model, showPrescription: true),
            if (model.isBusy)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: BusyIndicator()),
              )
            else if (model.hasError)
              _CategoryState(
                icon: Icons.cloud_off_rounded,
                title: 'No pudimos cargar este proveedor',
                message: 'Revisa tu conexión e inténtalo nuevamente.',
                actionLabel: 'Reintentar',
                onPressed: model.getVendorDetails,
              )
            else if (vendor.categories.isEmpty)
              const _CategoryState(
                icon: Icons.restaurant_menu_rounded,
                title: 'Menú en preparación',
                message: 'Este proveedor aún no tiene categorías disponibles.',
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Explora el menú',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              CustomGridView(
                noScrollPhysics: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: AppUISizes.getAspectRatio(
                  context,
                  AppStrings.categoryPerRow,
                  AppStrings.categoryImageHeight + 42,
                ),
                crossAxisCount: AppStrings.categoryPerRow,
                dataSet: vendor.categories,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemBuilder: (context, index) {
                  final category = vendor.categories[index];
                  return CategoryListItem(
                    h: AppStrings.categoryImageHeight + 20,
                    inverted: true,
                    category: category,
                    onPressed:
                        (category) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => VendorCategoryProductsPage(
                                  category: category,
                                  vendor: vendor,
                                ),
                          ),
                        ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryState extends StatelessWidget {
  const _CategoryState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 120),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

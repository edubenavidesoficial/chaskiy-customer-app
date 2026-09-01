import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/vendor_category_products.page.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Explora el menú',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 76,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: vendor.categories.length,
                    itemBuilder: (context, index) {
                      final category = vendor.categories[index];
                      return _CompactCategoryTile(
                        category: category,
                        onTap:
                            () => Navigator.of(context).push(
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

class _CompactCategoryTile extends StatelessWidget {
  const _CompactCategoryTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CustomImage(
                  imageUrl: category.imageUrl,
                  width: 52,
                  height: 52,
                  boxFit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
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

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor/vendor_reviews.page.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/bottomsheets/vendor_full_profie.bottomsheet.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/upload_prescription.btn.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/inputs/search_bar.input.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorDetailsHeader extends StatelessWidget {
  const VendorDetailsHeader(
    this.model, {
    this.showFeatureImage = true,
    this.featureImageHeight = 220,
    this.showPrescription = false,
    this.showSearch = true,
    super.key,
  });

  final VendorDetailsViewModel model;
  final bool showFeatureImage;
  final double featureImageHeight;
  final bool showPrescription;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vendor = model.vendor!;

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Column(
        children: [
          if (showFeatureImage)
            CustomImage(
              imageUrl: vendor.featureImage,
              height: featureImageHeight,
              canZoom: true,
            ).wFull(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? .22 : .07,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomImage(
                      imageUrl: vendor.logo,
                      boxFit: BoxFit.cover,
                      canZoom: true,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.3,
                          ),
                        ),
                        if (vendor.address.isNotEmptyAndNotNull &&
                            AppUISettings.showVendorAddress) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
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
                        const SizedBox(height: 8),
                        InkWell(
                          onTap:
                              () => context.nextPage(VendorReviewsPage(vendor)),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB000),
                                size: 20,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                vendor.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '(${vendor.reviews_count} reseñas)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      FavVendorTag(vendor),
                      const SizedBox(height: 4),
                      IconButton(
                        tooltip: 'Información',
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            () => openVendorDetailsBottomSheet(context, vendor),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _VendorMetaChip(
                  icon:
                      vendor.isOpen
                          ? Icons.check_circle_outline_rounded
                          : Icons.schedule_rounded,
                  label: vendor.isOpen ? 'Abierto' : 'Cerrado',
                  foreground:
                      vendor.isOpen ? const Color(0xFF087F5B) : colors.error,
                  background:
                      vendor.isOpen
                          ? const Color(0xFFDDF8ED)
                          : colors.errorContainer,
                ),
                if (vendor.delivery == 1)
                  const _VendorMetaChip(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Entrega',
                    foreground: Color(0xFF9A5B00),
                    background: Color(0xFFFFF0C2),
                  ),
                if (vendor.pickup == 1)
                  _VendorMetaChip(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Recoger',
                    foreground: colors.primary,
                    background: colors.primaryContainer,
                  ),
                _VendorMetaChip(
                  icon: Icons.schedule_rounded,
                  label: '${vendor.prepareTime} ${vendor.prepareTimeUnit}',
                ),
                _VendorMetaChip(
                  icon: Icons.directions_bike_outlined,
                  label: '${vendor.deliveryTime} ${vendor.deliveryTimeUnit}',
                ),
              ],
            ),
          ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarInput(
                hintText: 'Buscar en ${vendor.name}',
                onTap: model.openVendorSearch,
                showFilter: false,
              ),
            ),
          ],
          if (showPrescription) ...[
            const SizedBox(height: 14),
            UploadPrescriptionFab(model),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void openVendorDetailsBottomSheet(BuildContext context, Vendor vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => VendorFullProfileBottomSheet(vendor),
    );
  }
}

class _VendorMetaChip extends StatelessWidget {
  const _VendorMetaChip({
    required this.icon,
    required this.label,
    this.foreground,
    this.background,
  });

  final IconData icon;
  final String label;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveForeground = foreground ?? colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: background ?? colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: effectiveForeground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: effectiveForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

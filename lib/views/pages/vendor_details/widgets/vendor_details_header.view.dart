import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_hero.view.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_meta_chip.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/bottomsheets/vendor_full_profie.bottomsheet.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/upload_prescription.btn.dart';
import 'package:chaskiy/widgets/inputs/search_bar.input.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';

class VendorDetailsHeader extends StatelessWidget {
  const VendorDetailsHeader(
    this.model, {
    this.showFeatureImage = true,
    this.featureImageHeight = 210,
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
    final semantics = theme.semantics;
    final vendor = model.vendor!;

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Column(
        children: [
          if (showFeatureImage)
            VendorHeroView(model, height: featureImageHeight),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                if (showSearch)
                  Expanded(
                    child: SearchBarInput(
                      hintText: 'Buscar en ${vendor.name}',
                      onTap: model.openVendorSearch,
                      showFilter: false,
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 8),
                _HeaderAction(tooltip: 'Favorito', child: FavVendorTag(vendor)),
                const SizedBox(width: 8),
                _HeaderAction(
                  tooltip: 'Información',
                  icon: Icons.info_outline_rounded,
                  onTap: () => openVendorDetailsBottomSheet(context, vendor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  VendorMetaChip(
                    icon:
                        vendor.isOpen
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                    label: vendor.isOpen ? 'Abierto' : 'Cerrado',
                    foreground:
                        vendor.isOpen
                            ? semantics.onSuccessContainer
                            : colors.onErrorContainer,
                    background:
                        vendor.isOpen
                            ? semantics.successContainer
                            : colors.errorContainer,
                  ),
                  if (vendor.delivery == 1) ...[
                    const SizedBox(width: 8),
                    VendorMetaChip(
                      icon: Icons.delivery_dining_outlined,
                      label: 'Entrega',
                      foreground: semantics.onWarningContainer,
                      background: semantics.warningContainer,
                    ),
                  ],
                  if (vendor.pickup == 1) ...[
                    const SizedBox(width: 8),
                    VendorMetaChip(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Recoger',
                      foreground: colors.onPrimaryContainer,
                      background: colors.primaryContainer,
                    ),
                  ],
                  const SizedBox(width: 8),
                  VendorMetaChip(
                    icon: Icons.schedule_rounded,
                    label: _timeLabel(
                      vendor.prepareTime,
                      vendor.prepareTimeUnit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VendorMetaChip(
                    icon: Icons.directions_bike_outlined,
                    label: _timeLabel(
                      vendor.deliveryTime,
                      vendor.deliveryTimeUnit,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showPrescription) ...[
            const SizedBox(height: 10),
            UploadPrescriptionFab(model),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _timeLabel(String? value, String? unit) {
    final parts =
        [value, unit]
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();
    return parts.isEmpty ? 'Por confirmar' : parts.join(' ');
  }

  void openVendorDetailsBottomSheet(BuildContext context, Vendor vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => VendorFullProfileBottomSheet(vendor),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    this.icon,
    this.child,
    this.onTap,
  });

  final String tooltip;
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: child ?? Icon(icon, size: 21, color: colors.primary),
          ),
        ),
      ),
    );
  }
}

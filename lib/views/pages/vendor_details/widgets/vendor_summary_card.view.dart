import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

/// Resumen visual compartido por mercados con menús y con subcategorías.
class VendorSummaryCard extends StatelessWidget {
  const VendorSummaryCard({required this.vendor, super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final delivery = [
      vendor.deliveryTime?.trim() ?? '',
      vendor.deliveryTimeUnit?.trim() ?? '',
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
                    horizontal: 8,
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
                      fontSize: 11,
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

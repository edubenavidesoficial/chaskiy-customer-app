import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class FeaturedVendorListItem extends StatelessWidget {
  const FeaturedVendorListItem({
    required this.vendor,
    required this.onPressed,
    super.key,
  });

  final Vendor vendor;
  final Function(Vendor) onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = vendor.distance;
    final description =
        vendor.description
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(.12),
      child: InkWell(
        onTap: () => onPressed(vendor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: vendor.heroTag ?? vendor.id,
                    child: CustomImage(
                      imageUrl: vendor.featureImage,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                  if (!vendor.isOpen)
                    ColoredBox(color: AppColor.closeColor.withOpacity(.52)),
                  if (!vendor.isOpen)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _StatusPill(label: 'Closed'.tr()),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.94),
                        shape: BoxShape.circle,
                      ),
                      child: FavVendorTag(vendor),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 0,
                    child: Transform.translate(
                      offset: const Offset(0, 18),
                      child: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CustomImage(
                          imageUrl: vendor.vendorType.logo,
                          boxFit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description.isEmpty
                          ? vendor.vendorType.name
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vendor.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(
                          FlutterIcons.direction_ent,
                          color: AppColor.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance == null
                              ? '— km'
                              : '${distance.toStringAsFixed(2)} km',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _priceRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _priceRange {
    final min = vendor.minOrder ?? 0;
    final max = vendor.maxOrder ?? 0;
    return '${AppStrings.currencySymbol}${min.toStringAsFixed(2)} - '
        '${AppStrings.currencySymbol}${max.toStringAsFixed(2)}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

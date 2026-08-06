import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

class HorizontalVendorListItem extends StatelessWidget {
  //
  const HorizontalVendorListItem(
    this.vendor, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  //
  final Vendor vendor;
  final Function(Vendor) onPressed;

  static const _starColor = Color(0xFFFFB800);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(.08),
      child: InkWell(
        onTap: () => onPressed(vendor),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: vendor.heroTag ?? vendor.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomImage(
                    imageUrl: vendor.logo,
                    width: 58,
                    height: 58,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vendor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _ratingChip(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _starColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: _starColor),
          const SizedBox(width: 2),
          Text(
            vendor.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  //el backend manda la descripción con html: aquí solo interesa el texto
  String get _subtitle {
    if (vendor.categories.isNotEmpty) {
      return vendor.categories.take(2).map((c) => c.name).join(' · ');
    }
    final description =
        vendor.description
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
    return description.isNotEmpty ? description : vendor.vendorType.name;
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

/// Tarjeta que lleva a la tienda del producto.
class ProductVendorTile extends StatelessWidget {
  const ProductVendorTile({
    required this.vendor,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color:
          isDark
              ? Color.alphaBlend(
                theme.colorScheme.onSurface.withOpacity(.06),
                theme.colorScheme.surface,
              )
              : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1.5,
      shadowColor: Colors.black.withOpacity(.10),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipOval(
                child: CustomImage(
                  imageUrl: vendor.logo,
                  width: 46,
                  height: 46,
                  boxFit: BoxFit.cover,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver más productos de esta tienda',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

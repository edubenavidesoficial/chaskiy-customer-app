import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

class FoodHorizontalProductListItem extends StatelessWidget {
  //
  const FoodHorizontalProductListItem(
    this.product, {
    this.onPressed,
    required this.qtyUpdated,
    this.height,
    this.padding,
    Key? key,
  }) : super(key: key);

  //
  final Product product;
  final Function(Product)? onPressed;
  final Function(Product, int)? qtyUpdated;
  final double? height;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final imageSize = height ?? 84.0;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(.10),
        child: InkWell(
          onTap: onPressed == null ? null : () => onPressed!(product),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomImage(
                    imageUrl: product.photo,
                    width: imageSize,
                    height: imageSize,
                    boxFit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _priceRow(theme, currencySymbol),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(ThemeData theme, String currencySymbol) {
    final sellPrice =
        (product.showDiscount ? product.discountPrice : product.price)
            .convertCurrency
            .currencyValueFormat();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            '$currencySymbol$sellPrice',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
        ),
        //precio anterior solo cuando de verdad hay descuento
        if (product.showDiscount) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$currencySymbol${product.price.convertCurrency.currencyValueFormat()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

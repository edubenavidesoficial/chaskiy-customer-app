import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

/// Producto dentro del catálogo de una tienda.
///
/// Los productos marcados como destacados en el panel se muestran con la foto
/// grande arriba; el resto va en fila compacta.
class VendorMenuProductListItem extends StatelessWidget {
  const VendorMenuProductListItem(
    this.product, {
    this.onPressed,
    required this.qtyUpdated,
    this.height,
    this.padding,
    super.key,
  });

  final Product product;
  final Function(Product)? onPressed;
  final Function(Product, int)? qtyUpdated;
  final double? height;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 16, vertical: 5),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed == null ? null : () => onPressed!(product),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              //un degradado apenas perceptible le da volumen a la tarjeta sin
              //necesidad de sombras, que en fondo oscuro no se ven
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surfaceContainerHigh,
                  colors.surfaceContainerLow,
                ],
              ),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .55),
              ),
            ),
            child: _CompactLayout(product: product, height: height),
          ),
        ),
      ),
    );
  }
}

/// Producto normal: foto cuadrada a la izquierda.
class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.product, this.height});

  final Product product;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height ?? 112),
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          Hero(
            tag: product.heroTag ?? product.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CustomImage(
                imageUrl: product.photo,
                width: 80,
                height: 80,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: _ProductInfo(
              product: product,
              maxLines: 2,
              showDescription: true,
              showAvailability: true,
            ),
          ),
          const SizedBox(width: 10),
          _PriceAndAction(product: product),
        ],
      ),
    );
  }
}

/// Nombre, calificación y unidad.
class _ProductInfo extends StatelessWidget {
  const _ProductInfo({
    required this.product,
    required this.maxLines,
    this.showDescription = false,
    this.showAvailability = false,
  });

  final Product product;
  final int maxLines;
  final bool showDescription;
  final bool showAvailability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    //sin reseñas la fila solo mostraría "0.0 (0)", que no le dice nada a nadie
    final hasReviews = product.reviewsCount > 0;
    final unit = product.unit?.trim() ?? '';
    final detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.name,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        if (showDescription && product.description.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            product.description.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: detailStyle,
          ),
        ],
        if (showAvailability && product.availableQty != null) ...[
          const SizedBox(height: 4),
          Text(
            product.hasStock
                ? '${product.availableQty} disponibles'
                : 'Agotado',
            maxLines: 1,
            style: detailStyle?.copyWith(
              color: product.hasStock ? colors.onSurfaceVariant : colors.error,
            ),
          ),
        ],
        if (hasReviews || unit.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              if (hasReviews) ...[
                Icon(Icons.star_rounded, size: 17, color: theme.semantics.star),
                const SizedBox(width: 3),
                Text(
                  (product.rating ?? 0).toStringAsFixed(1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(' (${product.reviewsCount})', style: detailStyle),
              ],
              if (hasReviews && unit.isNotEmpty)
                Text(' · ', style: detailStyle),
              if (unit.isNotEmpty)
                Flexible(
                  child: Text(
                    unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: detailStyle,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// La misma acción y los mismos datos del producto, presentados en dos
/// columnas. El modo de visualización nunca altera el carrito ni la consulta.
class VendorMenuProductGridItem extends StatelessWidget {
  const VendorMenuProductGridItem(
    this.product, {
    this.onPressed,
    required this.qtyUpdated,
    super.key,
  });

  final Product product;
  final Function(Product)? onPressed;
  final Function(Product, int)? qtyUpdated;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed == null ? null : () => onPressed!(product),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .55),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: product.heroTag ?? product.id,
                  child: CustomImage(
                    imageUrl: product.photo,
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductInfo(
                      product: product,
                      maxLines: 2,
                      showAvailability: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _CompactPrice(product: product)),
                        const SizedBox(width: 6),
                        _AddButton(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactPrice extends StatelessWidget {
  const _CompactPrice({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final price = product.showDiscount ? product.discountPrice : product.price;
    final symbol = AppStrings.currentCurrencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$symbol${price.convertCurrency.currencyValueFormat()}',
          maxLines: 1,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (product.showDiscount)
          Text(
            '$symbol${product.price.convertCurrency.currencyValueFormat()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: product.hasStock ? colors.primary : colors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(
        HugeIcons.strokeRoundedPlusSign,
        color: product.hasStock ? colors.onPrimary : colors.onSurfaceVariant,
        size: 19,
      ),
    );
  }
}

/// Precio y botón de acción.
///
/// El botón abre el detalle del producto, igual que tocar la tarjeta: agregar
/// directo al carrito se saltaría las opciones que el producto pueda tener.
class _PriceAndAction extends StatelessWidget {
  const _PriceAndAction({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentPrice =
        product.showDiscount ? product.discountPrice : product.price;
    final symbol = AppStrings.currentCurrencySymbol;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$symbol${currentPrice.convertCurrency.currencyValueFormat()}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (product.showDiscount)
          Text(
            '$symbol${product.price.convertCurrency.currencyValueFormat()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            HugeIcons.strokeRoundedPlusSign,
            color: colors.onPrimary,
            size: 19,
          ),
        ),
      ],
    );
  }
}

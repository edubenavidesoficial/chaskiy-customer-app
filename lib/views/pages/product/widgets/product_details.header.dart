import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/views/pages/review/product_reviews.page.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/tags/product_tags.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailsHeader extends StatelessWidget {
  const ProductDetailsHeader({
    required this.product,
    this.showVendor = false,
    this.onRatingTap,
    Key? key,
  }) : super(key: key);

  final Product product;
  final bool showVendor;

  /// Acción al tocar las reseñas; por defecto abre la página de reseñas.
  final VoidCallback? onRatingTap;

  static const _successColor = Color(0xFF16A34A);
  static const _pickupColor = Color(0xFFB4552D);

  @override
  Widget build(BuildContext context) {
    //
    final theme = Theme.of(context);
    final currencySymbol = AppStrings.currentCurrencySymbol;

    return VStack([
      //nombre + precio
      HStack([
        Text(
          product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ).expand(),
        UiSpacer.hSpace(12),
        VStack([
          CurrencyHStack([
            Text(currencySymbol, style: _priceStyle(theme, 20)),
            Text(
              product.showDiscount
                  ? product.discountPrice.convertCurrency.currencyValueFormat()
                  : product.price.convertCurrency.currencyValueFormat(),
              style: _priceStyle(theme, 28),
            ),
          ], crossAlignment: CrossAxisAlignment.end),
          //precio anterior
          CustomVisibilty(
            visible: product.showDiscount,
            child: CurrencyHStack([
              currencySymbol.text.lineThrough.xs.make(),
              product.price.convertCurrency
                  .currencyValueFormat()
                  .text
                  .lineThrough
                  .sm
                  .medium
                  .make(),
            ]),
          ),
        ], crossAlignment: CrossAxisAlignment.end),
      ], crossAlignment: CrossAxisAlignment.start),

      UiSpacer.vSpace(10),
      //reseñas + entrega + datos del empaque
      Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ratingView(context, theme),
          _chip(
            label:
                product.canBeDelivered
                    ? "Deliverable".tr()
                    : "Not Deliverable".tr(),
            color: product.canBeDelivered ? _successColor : _pickupColor,
          ),
          if (_hasReadableSize)
            _chip(
              label: "${product.capacity} ${product.unit}",
              color: theme.colorScheme.onSurfaceVariant,
            ),
          if (product.packageCount != null)
            _chip(
              label: "%s Items".tr().fill(["${product.packageCount}"]),
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),

      //nombre de la tienda (opcional, se conserva la opción original)
      CustomVisibilty(
        visible: showVendor,
        child: product.vendor.name.text.lg.medium.make().pOnly(top: Vx.dp8),
      ),

      //
      ProductTags(product),
    ]);
  }

  /// El tamaño solo se muestra si la unidad trae texto: algunos productos
  /// llegan con un id numérico y se veía como "50 120".
  bool get _hasReadableSize {
    final capacity = product.capacity?.trim() ?? '';
    final unit = product.unit?.trim() ?? '';
    if (capacity.isEmpty || unit.isEmpty) return false;
    return RegExp(r'[a-zA-ZáéíóúñÁÉÍÓÚÑ]').hasMatch(unit);
  }

  /// Precio: grueso y, en modo oscuro, aclarado sobre el color de marca
  /// para que contraste bien con el fondo.
  TextStyle _priceStyle(ThemeData theme, double size) {
    final color =
        theme.brightness == Brightness.dark
            ? Color.lerp(AppColor.primaryColor, Colors.white, .34)!
            : AppColor.primaryColor;
    // se pide la variante Black a google_fonts: con `fontWeight` a secas
    // solo se carga la regular y el peso no se notaba
    return GoogleFonts.roboto(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: -.8,
      color: color,
    );
  }

  /// Estrella + reseñas; siempre abre la página de reseñas.
  Widget _ratingView(BuildContext context, ThemeData theme) {
    final hasReviews = product.reviewsCount > 0;
    final label =
        hasReviews
            ? "${(product.rating ?? 0).toStringAsFixed(1)} (${product.reviewsCount})"
            : 'Sin reseñas';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasReviews ? Icons.star_rounded : Icons.star_border_rounded,
          size: 17,
          color: AppColor.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    ).onTap(onRatingTap ?? () => context.nextPage(ProductReviewsPage(product)));
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

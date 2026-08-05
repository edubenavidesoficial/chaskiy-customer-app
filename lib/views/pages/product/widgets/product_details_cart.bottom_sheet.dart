import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailsCartBottomSheet extends StatelessWidget {
  const ProductDetailsCartBottomSheet({
    required this.model,
    this.backgroundColor,
    this.showBuyNow = false,
    Key? key,
  }) : super(key: key);

  final ProductDetailsViewModel model;

  /// Color de fondo de la barra; por defecto el de la superficie del tema.
  final Color? backgroundColor;

  /// Agrega el botón "Compra ahora" debajo (pantallas de comercio).
  final bool showBuyNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // mismo color que la hoja de contenido: sin corte de tono visible
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      // el SafeArea va dentro para que el color llegue hasta el borde
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: LoadingIndicator(
            loading: model.busy(model.product),
            loadingWidget: BusyIndicator().centered().box.make().wh(40, 40),
            child:
                model.product.hasStock
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _favouriteButton(theme),
                            const SizedBox(width: 12),
                            Expanded(child: _addToCartButton(theme)),
                          ],
                        ),
                        if (showBuyNow) ...[
                          const SizedBox(height: 10),
                          _buyNowButton(),
                        ],
                      ],
                    )
                    : "No stock"
                        .tr()
                        .text
                        .white
                        .semiBold
                        .makeCentered()
                        .p12()
                        .box
                        .red500
                        .withRounded(value: 30)
                        .make()
                        .wFull(context),
          ),
        ),
      ),
    );
  }

  /// Favorito: alterna entre agregar y quitar (antes solo dejaba agregar).
  Widget _favouriteButton(ThemeData theme) {
    final isFavourite = model.product.isFavourite;
    return Material(
      // en oscuro se apoya en la superficie (el tinte de marca desentonaba)
      color:
          theme.brightness == Brightness.dark
              ? theme.colorScheme.onSurface.withOpacity(.08)
              : AppColor.primaryColor.withOpacity(.10),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            model.isBusy
                ? null
                : !model.isAuthenticated()
                ? model.openLogin
                : isFavourite
                ? model.removeFromFavourite
                : model.addToFavourite,
        child: SizedBox(
          width: 58,
          height: 56,
          child:
              model.isBusy
                  ? BusyIndicator(color: AppColor.primaryColor).centered()
                  : Icon(
                    isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color:
                        isFavourite
                            ? const Color(0xFFFF5A5F)
                            : AppColor.primaryColor,
                    size: 24,
                  ),
        ),
      ),
    );
  }

  /// Compra directa: mismo método del ViewModel que el botón anterior.
  Widget _buyNowButton() {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.primaryColor.withOpacity(.55)),
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: model.isBusy ? null : model.buyNow,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Center(
            child: Text(
              "Buy Now".tr(),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addToCartButton(ThemeData theme) {
    final textColor = Utils.textColorByColor(AppColor.primaryColor);
    return Material(
      color: AppColor.primaryColor,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: AppColor.primaryColor.withOpacity(.45),
      child: InkWell(
        onTap: model.isBusy ? null : model.addToCart,
        child: SizedBox(
          height: 56,
          child:
              model.isBusy
                  ? BusyIndicator(color: textColor).centered()
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Add to cart".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        '  ·  ',
                        style: TextStyle(color: textColor.withOpacity(.7)),
                      ),
                      Text(
                        "${model.currencySymbol}${model.total.convertCurrency.currencyValueFormat()}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/views/pages/product/widgets/amazon/frequently_bought_together.view.dart';
import 'package:chaskiy/views/pages/product/widgets/commerce_product_options.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details.header.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_cart.bottom_sheet.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_floating.actions.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_image.header.dart';
import 'package:chaskiy/views/pages/product/widgets/product_qty.selector.dart';
import 'package:chaskiy/views/pages/product/widgets/product_vendor.tile.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'widgets/amazon/amazon_customer_product_reviews.dart';

class AmazonStyledCommerceProductDetailsPage extends StatelessWidget {
  AmazonStyledCommerceProductDetailsPage({required this.product, Key? key})
    : super(key: key);

  final Product product;

  /// cuánto monta la hoja de contenido sobre la cabecera
  static const double _sheetOverlap = 26;

  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductDetailsViewModel>.reactive(
      viewModelBuilder: () => ProductDetailsViewModel(context, product),
      onViewModelReady: (model) => model.getProductDetails(),
      builder: (context, model, child) {
        final theme = context.theme;
        // en modo claro la hoja lleva un tinte de marca muy suave para que
        // las tarjetas blancas del contenido resalten
        final sheetColor =
            theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : Color.alphaBlend(
                  AppColor.primaryColor.withOpacity(.05),
                  theme.colorScheme.surface,
                );

        return BasePage(
          showAppBar: false,
          backgroundColor: sheetColor,
          isLoading: model.isBusy || model.busy(model.product),
          body: Stack(
            children: [
              SmartRefresher(
                enablePullDown: true,
                controller: model.refreshController,
                onRefresh: () {
                  model.refreshController.refreshCompleted();
                  model.getProductDetails();
                },
                // Column (y no slivers) para que la hoja se pinte encima de
                // la cabecera y sus esquinas redondeadas queden a la vista
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //foto(s) del producto
                      ProductDetailsImageHeader(product: model.product),

                      //contenido sobre una hoja redondeada
                      Transform.translate(
                        offset: const Offset(0, -_sheetOverlap),
                        child: Container(
                          decoration: BoxDecoration(
                            color: sheetColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          padding: const EdgeInsets.only(top: 26, bottom: 190),
                          child: _content(context, model, theme),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //volver, compartir y carrito sobre la imagen
              ProductDetailsFloatingActions(model: model),
            ],
          ),
          bottomSheet: ProductDetailsCartBottomSheet(
            model: model,
            backgroundColor: sheetColor,
            showBuyNow: true,
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext context,
    ProductDetailsViewModel model,
    ThemeData theme,
  ) {
    return VStack([
      //nombre, precio, reseñas y etiquetas
      ProductDetailsHeader(
        product: model.product,
        onRatingTap: () => scrollTo(model.productReviewsKey),
      ).px20(),

      //descripción: el backend la envía en HTML; se limpia para mostrarla con
      //la tipografía y los colores del tema
      if (model.product.description.htmlToPlainText.isNotEmpty) ...[
        UiSpacer.vSpace(14),
        Text(
          model.product.description.htmlToPlainText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ).px20(),
      ],

      //sin stock
      if (!model.product.hasStock) ...[
        UiSpacer.vSpace(14),
        "No stock"
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
            .px20(),
      ],

      //opciones del producto (el widget trae su propio espaciado)
      CommerceProductOptions(model),

      //tienda del producto
      UiSpacer.vSpace(18),
      ProductVendorTile(
        vendor: model.product.vendor,
        onPressed: model.openVendorDetails,
      ).px20(),

      //cantidad
      if (model.product.hasStock) ...[
        UiSpacer.vSpace(18),
        ProductQtySelector(model: model).px20(),
      ],

      //frecuentemente comprados juntos
      UiSpacer.vSpace(18),
      FrequentlyBoughtTogetherView(model.product),

      //reseñas de clientes
      UiSpacer.vSpace(20),
      AmazonCustomerProductReview(
        product: model.product,
        key: model.productReviewsKey,
      ).px20(),
    ]);
  }

  //
  scrollTo(GlobalKey viewKey) {
    if (viewKey.currentContext != null) {
      Scrollable.ensureVisible(
        viewKey.currentContext!,
        duration: Duration(milliseconds: 500),
      );
    }
  }
}

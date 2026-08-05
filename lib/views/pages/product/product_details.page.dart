import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/option_group.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details.header.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_cart.bottom_sheet.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_floating.actions.dart';
import 'package:chaskiy/views/pages/product/widgets/product_details_image.header.dart';
import 'package:chaskiy/views/pages/product/widgets/product_option_group.dart';
import 'package:chaskiy/views/pages/product/widgets/product_options.header.dart';
import 'package:chaskiy/views/pages/product/widgets/product_qty.selector.dart';
import 'package:chaskiy/views/pages/product/widgets/product_vendor.tile.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailsPage extends StatelessWidget {
  ProductDetailsPage({required this.product, Key? key}) : super(key: key);

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
          body: Stack(
            children: [
              // Column (y no slivers) para que la hoja se pinte encima de la
              // cabecera y sus esquinas redondeadas queden a la vista
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //foto(s) del producto
                    ProductDetailsImageHeader(product: model.product),

                    //contenido sobre una hoja redondeada que monta la imagen
                    Transform.translate(
                      offset: const Offset(0, -_sheetOverlap),
                      child: Container(
                        decoration: BoxDecoration(
                          color: sheetColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 150),
                        child: _content(context, model, theme),
                      ),
                    ),
                  ],
                ),
              ),

              //volver, compartir y carrito sobre la imagen
              ProductDetailsFloatingActions(model: model),
            ],
          ),
          bottomSheet: ProductDetailsCartBottomSheet(
            model: model,
            backgroundColor: sheetColor,
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
      ProductDetailsHeader(product: model.product),

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
        ),
      ],

      //opciones del producto
      Visibility(
        visible: model.product.optionGroups.isNotEmpty,
        child: LoadingIndicator(
          loading: model.busy(model.product),
          child: VStack([
            UiSpacer.vSpace(18),
            ProductOptionsHeader(
              description:
                  "Select options to add them to the product/service".tr(),
            ),
            VStack([...buildProductOptions(model)]),
          ]),
        ),
      ),

      //tienda del producto
      UiSpacer.vSpace(18),
      ProductVendorTile(
        vendor: model.product.vendor,
        onPressed: model.openVendorPage,
      ),

      //cantidad
      if (model.product.hasStock) ...[
        UiSpacer.vSpace(18),
        ProductQtySelector(model: model),
      ],
    ]);
  }

  //
  List<Widget> buildProductOptions(ProductDetailsViewModel model) {
    return model.product.optionGroups.map((OptionGroup optionGroup) {
      return ProductOptionGroup(
        optionGroup: optionGroup,
        model: model,
      ).pOnly(bottom: Vx.dp12);
    }).toList();
  }
}

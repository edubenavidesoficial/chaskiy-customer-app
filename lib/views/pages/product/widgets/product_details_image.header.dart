import 'package:banner_carousel/banner_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/image_preview.dialog.dart';
import 'package:velocity_x/velocity_x.dart';

/// Cabecera con la(s) foto(s) del producto sobre un fondo decorativo suave.
/// Si el producto no tiene fotos se muestra un placeholder en lugar de un
/// espacio vacío.
class ProductDetailsImageHeader extends StatelessWidget {
  const ProductDetailsImageHeader({required this.product, Key? key})
    : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final height = context.percentHeight * 38;

    // la cabecera es clara en ambos temas: los íconos de la barra de estado
    // deben ir en oscuro para que se lean
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _DecorativeBackground(),
            if (product.photos.isEmpty)
              _placeholder()
            else
              BannerCarousel(
                customizedBanners:
                    product.photos.asMap().entries.map((entry) {
                      return CustomImage(
                        imageUrl: entry.value,
                        // llena toda la cabecera (sin franjas a los lados);
                        // la foto completa se ve al tocarla
                        boxFit: BoxFit.cover,
                        height: height,
                        width: context.percentWidth * 100,
                      ).onInkTap(
                        // el visor se abre sobre esta misma pantalla
                        () => showImagePreview(
                          context,
                          images: product.photos,
                          initialIndex: entry.key,
                        ),
                      );
                    }).toList(),
                customizedIndicators: IndicatorModel.animation(
                  width: 10,
                  height: 6,
                  spaceBetween: 2,
                  widthAnimation: 50,
                ),
                margin: EdgeInsets.zero,
                height: height,
                width: context.percentWidth * 100,
                activeColor: AppColor.primaryColor,
                disableColor: Colors.white.withOpacity(.65),
                animation: true,
                borderRadius: 0,
                indicatorBottom: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.inventory_2_rounded,
      size: 76,
      color: AppColor.primaryColor.withOpacity(.35),
    );
  }
}

/// Degradado + círculos difusos con el color de marca (igual en claro y
/// oscuro, tal como en el diseño).
class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground();

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(primary.withOpacity(.10), Colors.white),
            Color.alphaBlend(primary.withOpacity(.22), Colors.white),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -70,
            left: -60,
            child: _blob(180, primary.withOpacity(.16)),
          ),
          Positioned(
            bottom: -90,
            right: -70,
            child: _blob(240, primary.withOpacity(.24)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

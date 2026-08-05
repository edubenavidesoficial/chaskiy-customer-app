import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/views/shared/full_image_preview.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class CustomImage extends StatefulWidget {
  CustomImage({
    required this.imageUrl,
    this.height = Vx.dp40,
    this.width,
    this.boxFit,
    this.canZoom = false,
    this.hideDefaultImg = false,
    this.color,
    Key? key,
  }) : super(key: key);

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final bool canZoom;
  final bool hideDefaultImg;
  final Color? color;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final noImage =
        this.widget.imageUrl == null || this.widget.imageUrl!.trim().isEmpty;

    if (this.widget.hideDefaultImg &&
        (noImage || !this.widget.imageUrl.isNotDefaultImage)) {
      return 0.widthBox;
    }

    //sin imagen o imagen "default" del backend → placeholder elegante
    if (noImage || !this.widget.imageUrl.isNotDefaultImage) {
      return _fallbackView;
    }

    //
    //
    //if zooming is allowed, navigate to full image preview page
    if (this.widget.canZoom) {
      return GestureDetector(
        onTap: () {
          context.push(
            (context) => FullImagePreviewPage(
              this.widget.imageUrl!,
              boxFit: this.widget.boxFit ?? BoxFit.cover,
            ),
          );
        },
        child: _imageView,
      );
    }

    return _imageView;
  }

  Widget get _imageView {
    final normalizedUrl = Uri.parse(widget.imageUrl!.trim()).toString();

    //if is the link ends with .svg
    if (normalizedUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        normalizedUrl,
        fit: this.widget.boxFit ?? BoxFit.cover,
        height: this.widget.height,
        width: this.widget.width,
        color: this.widget.color,
      );
    }

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      // Evita decodificar fotografías enormes a resolución completa en
      // Android; conserva suficiente detalle para la dimensión mostrada.
      memCacheWidth: _cacheDimension(widget.width),
      memCacheHeight: _cacheDimension(widget.height),
      maxWidthDiskCache: 1440,
      maxHeightDiskCache: 1440,
      errorWidget: (context, imageUrl, _) => _fallbackView,
      fit: this.widget.boxFit ?? BoxFit.cover,
      progressIndicatorBuilder: (context, imageURL, progress) {
        // return BusyIndicator().centered();
        return Image.asset(
          AppImages.placeholder,
          fit: BoxFit.cover,
          height: this.widget.height,
          width: this.widget.width,
          color: this.widget.color,
        ).shimmer(
          primaryColor:
              context.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade200,
          secondaryColor:
              context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade50,
        );
      },
      height: this.widget.height,
      width: this.widget.width,
      color: this.widget.color,
    );
  }

  /// Placeholder cuando no hay imagen (o falla la carga): fondo suave del
  /// tema con el logo pequeño y tenue al centro — nunca estirado.
  Widget get _fallbackView {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: this.widget.height,
      width: this.widget.width,
      color: Color.alphaBlend(
        scheme.onSurface.withOpacity(.05),
        scheme.surface,
      ),
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: .38,
        heightFactor: .38,
        child: Opacity(
          opacity: .40,
          child: Image.asset(
            AppImages.appLogo,
            fit: BoxFit.contain,
            color: this.widget.color,
          ),
        ),
      ),
    );
  }

  int? _cacheDimension(double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final pixels = logicalSize * MediaQuery.devicePixelRatioOf(context);
    return pixels.round().clamp(64, 1440).toInt();
  }

  @override
  bool get wantKeepAlive => true;
}

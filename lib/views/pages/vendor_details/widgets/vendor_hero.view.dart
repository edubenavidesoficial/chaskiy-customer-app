import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor/vendor_reviews.page.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

/// Portada de la tienda: la foto ocupa todo el ancho y el nombre, el estado y
/// la calificación van encima, sobre un degradado.
///
/// Reemplaza a la tarjeta blanca que flotaba debajo de la foto y repetía el
/// logo que ya se ve en la portada.
class VendorHeroView extends StatelessWidget {
  const VendorHeroView(
    this.model, {
    required this.height,
    this.showDetails = true,
    super.key,
  });

  final VendorDetailsViewModel model;
  final double height;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.semantics;
    final vendor = model.vendor!;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImage(imageUrl: vendor.featureImage, height: height),

          //el degradado oscurece la parte de abajo para que el texto se lea
          //sobre cualquier foto, y funde la portada con el fondo de la página
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .42, 1],
                colors: [
                  Colors.black.withValues(alpha: .38),
                  Colors.black.withValues(alpha: .20),
                  Colors.black.withValues(alpha: .78),
                ],
              ),
            ),
          ),

          if (showDetails)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusPill(
                    isOpen: vendor.isOpen,
                    detail: _deliveryLabel(vendor),
                    semantics: semantics,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vendor.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _MetaLine(
                    vendor: vendor,
                    star: semantics.star,
                    onRatingTap:
                        () => context.nextPage(VendorReviewsPage(vendor)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tiempo de entrega tal como lo publica la tienda. Si no lo configuró, no
  /// se inventa un número: simplemente no se muestra.
  String? _deliveryLabel(Vendor vendor) {
    final value = vendor.deliveryTime?.trim() ?? '';
    if (value.isEmpty) return null;
    final unit = vendor.deliveryTimeUnit?.trim() ?? '';
    return 'entrega ${[value, unit].where((e) => e.isNotEmpty).join(' ')}';
  }
}

/// Pastilla de estado sobre la portada, con el punto de color y el tiempo.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.isOpen,
    required this.detail,
    required this.semantics,
  });

  final bool isOpen;
  final String? detail;
  final AppSemanticColors semantics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fill = _overPhotoTone(isOpen ? semantics.success : colors.error);
    final label = isOpen ? 'Abierto' : 'Cerrado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            detail == null ? label : '$label · $detail',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Lleva el color a una luminosidad fija, oscura y saturada.
  ///
  /// La pastilla va sobre una foto, no sobre el fondo del tema, así que el
  /// tono del tema claro (verde intenso) y el del oscuro (menta brillante)
  /// tienen que terminar igual de legibles con texto blanco encima.
  Color _overPhotoTone(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(.27)
        .withSaturation(hsl.saturation.clamp(.4, 1.0))
        .toColor();
  }
}

/// Dirección y calificación en una sola línea, separadas por puntos.
class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.vendor,
    required this.star,
    required this.onRatingTap,
  });

  final Vendor vendor;
  final Color star;
  final VoidCallback onRatingTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white.withValues(alpha: .88),
    );
    final showAddress =
        vendor.address.isNotEmptyAndNotNull && AppUISettings.showVendorAddress;

    return Row(
      children: [
        if (showAddress)
          Flexible(
            child: Text(
              vendor.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        if (showAddress) Text(' · ', style: style),
        InkWell(
          onTap: onRatingTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 17, color: star),
              const SizedBox(width: 3),
              Text(
                vendor.rating.toStringAsFixed(1),
                style: style?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text('(${vendor.reviews_count} reseñas)', style: style),
            ],
          ),
        ),
      ],
    );
  }
}

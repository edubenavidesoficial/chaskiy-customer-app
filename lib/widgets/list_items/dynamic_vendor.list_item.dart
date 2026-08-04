import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/buttons/route.button.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';
import 'package:velocity_x/velocity_x.dart';

class DynamicVendorListItem extends StatelessWidget {
  const DynamicVendorListItem(
    this.vendor, {
    required this.onPressed,
    this.width,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;
  final Function(Vendor)? onPressed;
  final double? width;

  static const _successColor = Color(0xFF16A34A);
  static const _closedColor = Color(0xFFE53935);
  static const _starColor = Color(0xFFFFB800);

  // escala de grises para negocios cerrados
  static const _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        elevation: 2.5,
        shadowColor: Colors.black.withOpacity(.10),
        child: InkWell(
          onTap: onPressed == null ? null : () => onPressed!(vendor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBanner(),
              _buildInfo(theme),
            ],
          ),
        ),
      ),
    ).px12();
  }

  Widget _buildBanner() {
    // width/height explícitos = resolución de decodificación correcta
    Widget image = Hero(
      tag: vendor.heroTag ?? vendor.id,
      child: CustomImage(
        imageUrl: vendor.featureImage,
        width: 800,
        height: 400,
        boxFit: BoxFit.cover,
      ),
    );
    if (!vendor.isOpen) {
      image = ColorFiltered(colorFilter: _grayscaleFilter, child: image);
    }

    return AspectRatio(
      aspectRatio: 16 / 7.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (vendor.isOpen)
            const Positioned(top: 10, left: 10, child: _StatusPill(open: true))
          else
            const Center(child: _StatusPill(open: false, big: true)),
          Positioned(
            top: 8,
            right: 8,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: ColoredBox(
                  color: Colors.black.withOpacity(.22),
                  child: FavVendorTag(vendor),
                ),
              ),
            ),
          ),
          // botón de ruta en mapa (se conserva la funcionalidad original)
          if (!vendor.latitude.isEmptyOrNull && !vendor.longitude.isEmptyOrNull)
            Positioned(
              bottom: 8,
              right: 8,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(.22),
                    padding: const EdgeInsets.all(2),
                    child: RouteButton(vendor, size: 14),
                  ),
                ),
              ),
            )
          else
            UiSpacer.emptySpace(),
        ],
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // logo del negocio
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImage(
                imageUrl: vendor.logo,
                width: 84,
                height: 84,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ratingChip(theme),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _deliveryChip(theme),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _metaLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _starColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: _starColor),
          const SizedBox(width: 2),
          Text(
            _ratingLabel,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryChip(ThemeData theme) {
    final String label;
    final Color color;
    if (vendor.delivery == 1) {
      final free = vendor.deliveryFee <= 0 &&
          vendor.baseDeliveryFee <= 0 &&
          vendor.chargePerKm <= 0;
      label = free ? 'Envío gratis' : 'Envío a domicilio';
      color = _successColor;
    } else {
      label = 'Solo recoger';
      color = const Color(0xFFB4552D);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ── datos derivados (solo lo que el backend afirma) ────────────────

  String get _subtitle {
    if (vendor.categories.isNotEmpty) {
      return vendor.categories.take(2).map((c) => c.name).join(' · ');
    }
    final description = vendor.description
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return description.isNotEmpty ? description : vendor.vendorType.name;
  }

  String get _ratingLabel {
    final rating = vendor.rating.toStringAsFixed(1);
    return vendor.reviews_count > 0
        ? '$rating (${vendor.reviews_count})'
        : rating;
  }

  String get _metaLine {
    final parts = <String>[];
    final distance = vendor.distance;
    if (distance != null && distance > 0 && distance <= 150) {
      parts.add(
        distance < 10
            ? '${distance.toStringAsFixed(1)} km'
            : '${distance.toStringAsFixed(0)} km',
      );
    }
    final time = vendor.deliveryTime;
    if (time != null && time.trim().isNotEmpty) {
      final unit = (vendor.deliveryTimeUnit ?? '').trim();
      parts.add('$time ${unit.startsWith('min') ? 'min' : unit}'.trim());
    }
    return parts.join(' · ');
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.open, this.big = false});

  final bool open;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final color = open
        ? DynamicVendorListItem._successColor
        : DynamicVendorListItem._closedColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          color: Colors.black.withOpacity(.30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: big ? 8 : 7,
                height: big ? 8 : 7,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: big ? 6 : 5),
              Text(
                open ? 'Abierto' : 'Cerrado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: big ? 13 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

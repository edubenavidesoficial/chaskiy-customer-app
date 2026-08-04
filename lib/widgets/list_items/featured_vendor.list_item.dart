import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/tags/fav_vendor.tag.dart';

class FeaturedVendorListItem extends StatelessWidget {
  const FeaturedVendorListItem({
    required this.vendor,
    required this.onPressed,
    super.key,
  });

  final Vendor vendor;
  final Function(Vendor) onPressed;

  static const _successColor = Color(0xFF16A34A);
  static const _closedColor = Color(0xFFE53935);
  static const _starColor = Color(0xFFFFB800);

  // Escala de grises para negocios cerrados (más elegante que el tinte rojo)
  static const _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(.10),
      child: InkWell(
        onTap: () => onPressed(vendor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImageHeader()),
            _buildInfoBody(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    // width/height explícitos: definen la resolución de decodificación
    // (sin ellos CustomImage decodifica a 40dp y la foto se ve pixelada;
    // el layout real lo impone el Stack con fit expand)
    Widget image = Hero(
      tag: vendor.heroTag ?? vendor.id,
      child: CustomImage(
        imageUrl: vendor.featureImage,
        width: 360,
        height: 280,
        boxFit: BoxFit.cover,
      ),
    );
    if (!vendor.isOpen) {
      image = ColorFiltered(colorFilter: _grayscaleFilter, child: image);
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        image,
        // abierto: pill discreto arriba; cerrado: pill centrado y protagonista
        if (vendor.isOpen)
          const Positioned(top: 10, left: 10, child: _StatusPill.open())
        else
          const Center(child: _StatusPill.closed()),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.94),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 6,
                ),
              ],
            ),
            child: FavVendorTag(vendor),
          ),
        ),
        Positioned(
          left: 12,
          bottom: -18,
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImage(
                imageUrl: vendor.logo,
                width: 80,
                height: 80,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBody(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vendor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
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
          const SizedBox(height: 7),
          // meta inline: ★ 5.0 (12) · 2.4 km · 40 min
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: _starColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _ratingLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (_metaTail.isNotEmpty)
                        TextSpan(
                          text: _metaTail,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _deliveryChip(theme),
        ],
      ),
    );
  }

  // ── datos derivados ────────────────────────────────────────────────

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

  String get _metaTail {
    final parts = <String>[];
    final distance = _distanceLabel;
    final time = _timeLabel;
    if (distance != null) parts.add(distance);
    if (time != null) parts.add(time);
    return parts.isEmpty ? '' : '  ·  ${parts.join('  ·  ')}';
  }

  // distancias absurdas (negocio sin coordenadas) no se muestran
  String? get _distanceLabel {
    final distance = vendor.distance;
    if (distance == null || distance <= 0 || distance > 150) return null;
    return distance < 10
        ? '${distance.toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} km';
  }

  String? get _timeLabel {
    final time = vendor.deliveryTime;
    if (time == null || time.trim().isEmpty) return null;
    final unit = (vendor.deliveryTimeUnit ?? '').trim();
    final shortUnit = unit.startsWith('min') ? 'min' : unit;
    return '$time $shortUnit'.trim();
  }

  Widget _deliveryChip(ThemeData theme) {
    final String label;
    final Color color;
    if (vendor.delivery == 1) {
      // el costo real lo calcula el backend al ordenar (base + por km),
      // así que solo se presume "gratis" cuando todos los cargos son cero
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill.open()
      : open = true,
        centered = false;

  const _StatusPill.closed()
      : open = false,
        centered = true;

  final bool open;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final color = open
        ? FeaturedVendorListItem._successColor
        : FeaturedVendorListItem._closedColor;
    return Container(
      padding: centered
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: centered ? 8 : 7,
            height: centered ? 8 : 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: centered ? 6 : 5),
          Text(
            open ? 'Abierto' : 'Cerrado',
            style: TextStyle(
              color: color,
              fontSize: centered ? 13 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

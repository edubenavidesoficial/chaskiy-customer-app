import 'package:flutter/material.dart';

/// Pastilla con un dato de la tienda: si está abierta, si entrega, cuánto
/// tarda.
///
/// Vive aparte porque el encabezado y la ficha completa muestran los mismos
/// datos y antes cada uno los pintaba a su manera.
class VendorMetaChip extends StatelessWidget {
  const VendorMetaChip({
    required this.icon,
    required this.label,
    this.foreground,
    this.background,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveForeground = foreground ?? colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveForeground),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: effectiveForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

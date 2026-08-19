import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/utils/order_status_localizer.dart';

/// Estado del pedido como pastilla de color.
///
/// Los colores de estado los configura el panel y llegan sin pensar en el
/// fondo: `preparingColor` es azul puro y `enrouteColor` verde puro, así que
/// como texto suelto sobre la tarjeta apenas se leían en tema oscuro. Aquí el
/// estado se traduce a los colores del tema, que ya vienen en pareja fondo y
/// texto con contraste en claro y en oscuro.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _paletteFor(theme);
    final label = spanishOrderStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _paletteFor(ThemeData theme) {
    final scheme = theme.colorScheme;
    final semantics = theme.semantics;

    //entregado
    if (["delivered", "completed", "successful"].contains(status)) {
      return (
        background: semantics.successContainer,
        foreground: semantics.onSuccessContainer,
      );
    }
    //no llegó a completarse
    if (["failed", "fail", "cancelled", "cancel"].contains(status)) {
      return (
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      );
    }
    //todavía no lo toma el negocio
    if (["pending", "scheduled"].contains(status)) {
      return (
        background: semantics.warningContainer,
        foreground: semantics.onWarningContainer,
      );
    }
    //preparando, listo o en camino: el pedido avanza
    return (
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
    );
  }
}

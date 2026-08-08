import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

/// Tarjeta de sección de la pantalla de confirmación del pedido.
///
/// Agrupa cada bloque —entrega, propina, pago, resumen— en una ficha con
/// ícono y título, para que la pantalla se lea como un detalle de pedido y
/// no como un formulario suelto.
class CheckoutSectionView extends StatelessWidget {
  const CheckoutSectionView({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.accentColor,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = accentColor ?? colors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: VStack([
        HStack([
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          12.widthBox,
          VStack([
            title.text.semiBold.lg.make(),
            if (subtitle != null)
              subtitle!.text.sm
                  .color(colors.onSurfaceVariant)
                  .make()
                  .pOnly(top: 2),
          ]).expand(),
          if (trailing != null) trailing!,
        ]),
        child.pOnly(top: Vx.dp16),
      ]),
    );
  }
}

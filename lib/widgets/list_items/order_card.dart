import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Recuadro común de las tarjetas de pedido: comercio, reserva y taxi.
///
/// Cada lista traía su propio recuadro con radio, borde y sombra distintos, así
/// que en la misma pantalla convivían tres tarjetas diferentes. El contenido lo
/// pone cada tipo de pedido; el recuadro y el botón de pago viven aquí.
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.child,
    required this.onPressed,
    this.onPayPressed,
    super.key,
  });

  final Widget child;
  final Function onPressed;

  /// Botón de pago al pie. Solo se muestra cuando se recibe.
  final Function? onPayPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.all(14), child: child),
              if (onPayPressed != null)
                CustomButton(
                  title: "PAY FOR ORDER".tr(),
                  icon: FlutterIcons.credit_card_fea,
                  iconSize: 18,
                  height: 46,
                  shapeRadius: 0,
                  onPressed: onPayPressed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

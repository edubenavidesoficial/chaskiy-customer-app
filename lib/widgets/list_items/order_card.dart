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
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: scheme.surface,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.all(14), child: child),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  onPayPressed == null ? 12 : 7,
                ),
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () => onPressed(),
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Ver detalle'.tr(),
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (onPayPressed != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CustomButton(
                    title: "PAY FOR ORDER".tr(),
                    icon: FlutterIcons.credit_card_fea,
                    iconSize: 18,
                    height: 44,
                    shapeRadius: 15,
                    onPressed: onPayPressed,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

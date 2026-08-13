import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderBottomSheet extends StatelessWidget {
  const OrderBottomSheet(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (!vm.order.canCancel || vm.isBusy) return UiSpacer.emptySpace();

    final theme = Theme.of(context);
    final loading = vm.busy(vm.order);

    //cancelar no es la acción principal de la pantalla: un bloque rojo entero
    //abajo pesaba más que el propio pedido
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : () => vm.cancelOrder(),
              icon:
                  loading
                      ? const SizedBox.shrink()
                      : const Icon(FlutterIcons.close_ant, size: 18),
              label:
                  loading
                      ? BusyIndicator(color: theme.colorScheme.error)
                      : Text("Cancel Order".tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(
                  color: theme.colorScheme.error.withValues(alpha: .5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

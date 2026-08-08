import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/view_models/checkout_base.vm.dart';
import 'package:chaskiy/views/pages/checkout/widgets/checkout_section.view.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Propina para el conductor: montos sugeridos en un toque y monto libre.
///
/// Cada cambio recalcula el total del pedido. Antes la propina se mostraba en
/// el resumen pero no se sumaba al total salvo que el cliente presionara
/// "listo" en el teclado, y terminaba pagando más de lo que veía.
class DriverTipView extends StatefulWidget {
  const DriverTipView(this.vm, {Key? key}) : super(key: key);

  final CheckoutBaseViewModel vm;

  @override
  State<DriverTipView> createState() => _DriverTipViewState();
}

class _DriverTipViewState extends State<DriverTipView> {
  /// Montos sugeridos, en la moneda base de la app.
  static const List<int> _suggestedTips = [0, 1, 2, 5];

  final FocusNode _customTipFocusNode = FocusNode();
  bool _useCustomTip = false;

  @override
  void initState() {
    super.initState();
    _useCustomTip = !_suggestedTips.contains(_currentTip);
    _customTipFocusNode.addListener(_onCustomTipFocusChange);
  }

  @override
  void dispose() {
    _customTipFocusNode.removeListener(_onCustomTipFocusChange);
    _customTipFocusNode.dispose();
    super.dispose();
  }

  int get _currentTip => int.tryParse(widget.vm.driverTipTEC.text.trim()) ?? 0;

  /// Al salir del campo de monto libre se recalcula, para no depender de que
  /// el cliente presione "listo" en el teclado.
  void _onCustomTipFocusChange() {
    if (!_customTipFocusNode.hasFocus) {
      widget.vm.setDriverTip(widget.vm.driverTipTEC.text);
    }
  }

  void _selectSuggestedTip(int amount) {
    setState(() => _useCustomTip = false);
    widget.vm.setDriverTip("$amount");
  }

  void _enableCustomTip() {
    setState(() => _useCustomTip = true);
    _customTipFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = AppStrings.currentCurrencySymbol;

    return CheckoutSectionView(
      icon: HugeIcons.strokeRoundedTips,
      title: "Driver Tip".tr(),
      subtitle: "Optional, goes entirely to the driver".tr(),
      child: VStack([
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._suggestedTips.map(
              (amount) => _TipChip(
                label:
                    amount == 0
                        ? "No tip".tr()
                        : "$currencySymbol $amount".currencyFormat(
                          currencySymbol,
                        ),
                selected: !_useCustomTip && _currentTip == amount,
                onTap: () => _selectSuggestedTip(amount),
              ),
            ),
            _TipChip(
              label: "Other amount".tr(),
              selected: _useCustomTip,
              onTap: _enableCustomTip,
            ),
          ],
        ),
        if (_useCustomTip)
          CustomTextFormField(
            labelText: "Other amount".tr() + " ($currencySymbol)",
            textEditingController: widget.vm.driverTipTEC,
            focusNode: _customTipFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onFieldSubmitted:
                (value) =>
                    widget.vm.setDriverTip("${widget.vm.driverTipTEC.text}"),
          ).pOnly(top: Vx.dp16),
      ]),
    );
  }
}

/// Pastilla de monto sugerido.
class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child:
          label.text
              .color(selected ? colors.onPrimary : colors.onSurface)
              .medium
              .make(),
    ).onInkTap(onTap);
  }
}

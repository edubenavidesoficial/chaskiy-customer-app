import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Fila "Cantidad" con selector en forma de píldora.
/// Usa el mismo flujo del ViewModel (updatedSelectedQty).
class ProductQtySelector extends StatelessWidget {
  const ProductQtySelector({required this.model, Key? key}) : super(key: key);

  final ProductDetailsViewModel model;

  int get _max =>
      (model.product.availableQty != null && model.product.availableQty! > 0)
          ? model.product.availableQty!
          : 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = model.product.selectedQty;
    final canDecrease = qty > 1;
    final canIncrease = qty < _max;

    return Row(
      children: [
        Expanded(
          child: Text(
            "Quantity".tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 6, right: 4, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(.06),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roundButton(
                icon: Icons.remove_rounded,
                enabled: canDecrease,
                filled: false,
                theme: theme,
                onTap: () => model.updatedSelectedQty(qty - 1),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                alignment: Alignment.center,
                child: Text(
                  "$qty",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _roundButton(
                icon: Icons.add_rounded,
                enabled: canIncrease,
                filled: true,
                theme: theme,
                onTap: () => model.updatedSelectedQty(qty + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roundButton({
    required IconData icon,
    required bool enabled,
    required bool filled,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final background =
        filled
            ? (enabled
                ? AppColor.primaryColor
                : AppColor.primaryColor.withOpacity(.35))
            : Colors.transparent;
    final iconColor =
        filled
            ? Utils.textColorByColor(AppColor.primaryColor)
            : theme.colorScheme.onSurface.withOpacity(enabled ? .75 : .28);

    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

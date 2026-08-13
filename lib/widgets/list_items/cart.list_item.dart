import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/cart.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CartListItem extends StatelessWidget {
  const CartListItem(
    this.cart, {
    required this.onQuantityChange,
    this.deleteCartItem,
    Key? key,
  }) : super(key: key);

  final Cart cart;
  final Function(int) onQuantityChange;
  final Function? deleteCartItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final quantity = cart.selectedQty ?? 1;
    final unitPrice = cart.price ?? cart.product!.sellPrice;
    final maxQuantity = cart.product?.availableQty ?? 20;

    return Row(
      children: [
        CustomImage(
          imageUrl: cart.product!.photo,
          width: 64,
          height: 64,
        ).cornerRadius(14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${cart.product?.name}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (cart.optionsSentence.isNotEmpty)
                Text(
                  cart.optionsSentence,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                "$currencySymbol${(unitPrice * quantity).convertCurrency}"
                    .currencyFormat(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              //el precio de arriba ya es el de la línea, así que el unitario
              //solo hace falta cuando hay más de uno
              if (quantity > 1)
                Text(
                  "$quantity × ${"$currencySymbol${unitPrice.convertCurrency}".currencyFormat()}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _QuantityControl(
          quantity: quantity,
          canAdd: quantity < maxQuantity,
          onAdd: () => onQuantityChange(quantity + 1),
          onRemove:
              quantity > 1
                  ? () => onQuantityChange(quantity - 1)
                  : deleteCartItem == null
                  ? null
                  : () => deleteCartItem!(),
        ),
      ],
    );
  }
}

/// Control de cantidad del carrito.
///
/// Cuando queda una unidad, el botón de restar pasa a ser un tacho: es como se
/// quita un producto en las apps de pedidos y evita el aspa roja que antes
/// tapaba una esquina de la foto.
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _action(
            icon:
                quantity > 1
                    ? Icons.remove_rounded
                    : Icons.delete_outline_rounded,
            color: quantity > 1 ? scheme.onSurface : scheme.error,
            onPressed: onRemove,
          ),
          SizedBox(
            width: 20,
            child: Text(
              "$quantity",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _action(
            icon: Icons.add_rounded,
            color: canAdd ? scheme.primary : scheme.outline,
            onPressed: canAdd ? onAdd : null,
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
    );
  }
}

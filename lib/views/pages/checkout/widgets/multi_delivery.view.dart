import 'package:flutter/material.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/view_models/checkout_base.vm.dart';

class MultiDeliveryView extends StatelessWidget {
  const MultiDeliveryView(this.vm, {super.key});

  final CheckoutBaseViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (!vm.canUseMultiDelivery) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final enabled = vm.checkout?.useMultiDelivery == true;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            value: enabled,
            onChanged: vm.toggleMultiDelivery,
            title: const Text('Entregar en varias direcciones'),
            subtitle: Text(
              'Un conductor realizará toda la ruta. Cada dirección tiene su tarifa.',
              style: theme.textTheme.bodySmall,
            ),
            secondary: const Icon(Icons.route_outlined),
          ),
          if (enabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (
                    var index = 0;
                    index < vm.checkout!.deliveries.length;
                    index++
                  )
                    _DeliveryCard(vm: vm, index: index),
                  OutlinedButton.icon(
                    onPressed:
                        vm.checkout!.deliveries.length >= 10
                            ? null
                            : vm.addMultiDeliveryAddress,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Agregar otra dirección'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        vm.multiDeliveryDistributionIsValid
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        size: 18,
                        color:
                            vm.multiDeliveryDistributionIsValid
                                ? Colors.green
                                : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.multiDeliveryDistributionIsValid
                              ? 'Todas las unidades están distribuidas.'
                              : 'Agrega al menos dos direcciones y distribuye todas las unidades.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                vm.multiDeliveryDistributionIsValid
                                    ? Colors.green.shade700
                                    : theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vm.checkout!.deliveries.length} entregas × '
                    '\$${vm.vendor!.perDeliveryFee.toStringAsFixed(2)}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.vm, required this.index});

  final CheckoutBaseViewModel vm;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delivery = vm.checkout!.deliveries[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 16, child: Text('${index + 1}')),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.deliveryAddress.name ?? 'Entrega ${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      delivery.deliveryAddress.address ?? '',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (index > 0)
                IconButton(
                  tooltip: 'Eliminar dirección',
                  onPressed: () => vm.removeMultiDelivery(index),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const Divider(height: 20),
          for (
            var lineIndex = 0;
            lineIndex < CartServices.productsInCart.length;
            lineIndex++
          )
            _ProductQuantityRow(vm: vm, stopIndex: index, lineIndex: lineIndex),
        ],
      ),
    );
  }
}

class _ProductQuantityRow extends StatelessWidget {
  const _ProductQuantityRow({
    required this.vm,
    required this.stopIndex,
    required this.lineIndex,
  });

  final CheckoutBaseViewModel vm;
  final int stopIndex;
  final int lineIndex;

  @override
  Widget build(BuildContext context) {
    final cart = CartServices.productsInCart[lineIndex];
    final current = vm.checkout!.deliveries[stopIndex].quantityFor(lineIndex);
    final max = vm.maxQuantityForLine(stopIndex, lineIndex);
    final values = List<int>.generate(max + 1, (index) => index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cart.product?.name ?? 'Producto'),
                if (cart.optionsSentence.isNotEmpty)
                  Text(
                    cart.optionsSentence,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: current.clamp(0, max),
            items:
                values
                    .map(
                      (quantity) => DropdownMenuItem(
                        value: quantity,
                        child: Text('$quantity'),
                      ),
                    )
                    .toList(),
            onChanged: (quantity) {
              if (quantity != null) {
                vm.changeDeliveryQuantity(stopIndex, lineIndex, quantity);
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/views/pages/cart/cart.page.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';

/// Barra fija con el resumen del carrito.
///
/// Aparece sobre el catálogo, así que lleva degradado y sombra hacia arriba
/// para despegarse del contenido que pasa por debajo.
class CartViewBottomSheet extends StatelessWidget {
  const CartViewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppUISettings.showCart) {
      return const SizedBox.shrink();
    }
    //
    return StreamBuilder<int>(
      stream: CartServices.cartItemsCountStream.stream,
      initialData: CartServices.productsInCart.length,
      builder: (context, snapshot) {
        //
        final count = snapshot.data ?? 0;
        if (count == 0) {
          return const SizedBox.shrink();
        }
        //
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final total =
            "${AppStrings.currentCurrencySymbol} ${CartServices.totalSubtotal.convertCurrency}"
                .currencyFormat();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.surfaceContainerHigh, colors.surface],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: .6),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? .34 : .10,
                ),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  _CartCountBadge(count: count),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          count == 1 ? '1 producto' : '$count productos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          total,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    title: 'Ver carrito',
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    iconSize: 19,
                    height: 50,
                    isFixedHeight: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => CartPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bolsa con la cantidad de productos encima.
class _CartCountBadge extends StatelessWidget {
  const _CartCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            HugeIcons.strokeRoundedShoppingBag01,
            size: 21,
            color: colors.onPrimaryContainer,
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            constraints: const BoxConstraints(minWidth: 20),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.surface, width: 2),
            ),
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/view_models/cart.vm.dart';
import 'package:chaskiy/views/pages/cart/widgets/amount_tile.dart';
import 'package:chaskiy/views/pages/cart/widgets/apply_coupon.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/cart.list_item.dart';
import 'package:chaskiy/widgets/states/cart.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<CartViewModel>.reactive(
      viewModelBuilder: () => CartViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "My Cart".tr(),
          //el carrito se lee como una hoja: barra y fondo del mismo tono, sin
          //el bloque azul que cortaba la pantalla en dos
          appBarColor: theme.colorScheme.surfaceContainerLow,
          appBarItemColor: theme.colorScheme.onSurface,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          elevation: 0,
          //el botón se queda fijo abajo: antes había que bajar hasta el final
          //del resumen para encontrarlo
          bottomNavigationBar:
              model.cartItems.isEmpty ? null : _checkoutBar(context, model),
          body: SafeArea(
            child:
                model.cartItems.isEmpty
                    ? Center(child: EmptyCart())
                    : ListView(
                      key: model.pageKey,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _section(context, child: _items(context, model)),
                        const SizedBox(height: 16),
                        _section(context, child: ApplyCoupon(model)),
                        const SizedBox(height: 16),
                        _section(context, child: _summary(context, model)),
                      ],
                    ),
          ),
        );
      },
    );
  }

  /// Bloque blanco con esquinas redondeadas: separa carrito, cupón y resumen.
  Widget _section(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _items(BuildContext context, CartViewModel model) {
    final theme = Theme.of(context);

    return CustomListView(
      padding: EdgeInsets.zero,
      noScrollPhysics: true,
      dataSet: model.cartItems,
      separatorBuilder:
          (_, __) =>
              Divider(height: 26, color: theme.colorScheme.outlineVariant),
      itemBuilder: (context, index) {
        final cart = model.cartItems[index];
        final product = cart.product;
        return InkWell(
          onTap: () => model.productSelected(product!),
          child: CartListItem(
            key: Key("${cart.product?.id}:$index"),
            cart,
            onQuantityChange: (qty) => model.updateCartItemQuantity(qty, index),
            deleteCartItem: () => model.deleteCartItem(index),
          ),
        );
      },
    );
  }

  Widget _summary(BuildContext context, CartViewModel model) {
    final theme = Theme.of(context);
    final summaryStyle = theme.textTheme.bodyLarge;
    final totalStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmountTile(
          "Total Item".tr(),
          model.totalCartItems.toString(),
          amountStyle: summaryStyle,
        ),
        const SizedBox(height: 6),
        AmountTile(
          "Sub-Total".tr(),
          _amount(model.subTotalPrice, model.currencySymbol),
          amountStyle: summaryStyle,
        ),
        if (model.coupon != null && !model.coupon!.for_delivery) ...[
          const SizedBox(height: 6),
          AmountTile(
            "Discount".tr(),
            _amount(model.discountCartPrice, model.currencySymbol),
            amountStyle: summaryStyle,
          ),
        ],
        if (model.coupon != null && model.coupon!.for_delivery) ...[
          const SizedBox(height: 6),
          Text(
            "Discount will be applied to delivery fee on checkout".tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        Divider(height: 26, color: theme.colorScheme.outlineVariant),
        AmountTile(
          "Total".tr(),
          _amount(model.totalCartPrice, model.currencySymbol),
          amountStyle: totalStyle,
        ),
      ],
    );
  }

  Widget _checkoutBar(BuildContext context, CartViewModel model) {
    final theme = Theme.of(context);

    return Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total".tr(),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    _amount(model.totalCartPrice, model.currencySymbol),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  title: "CHECKOUT".tr(),
                  onPressed: model.checkoutPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _amount(double value, String currencySymbol) =>
      "$currencySymbol ${value.convertCurrency}".currencyFormat();
}

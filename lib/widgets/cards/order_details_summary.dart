import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/views/pages/cart/widgets/amount_tile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderDetailsSummary extends StatelessWidget {
  const OrderDetailsSummary(this.order, {Key? key}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = AppStrings.currencySymbol;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final amountStyle = theme.textTheme.bodyMedium;
    final totalStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    Widget line(String title, String amount) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AmountTile(
        title,
        amount,
        titleStyle: labelStyle,
        amountStyle: amountStyle,
      ),
    );

    String money(dynamic value) =>
        "$currencySymbol ${value ?? 0}".currencyFormat(currencySymbol);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //el subtotal salía sin símbolo, era la única fila sin moneda
        line("Subtotal".tr(), money(order.subTotal)),
        line("Discount".tr(), "- ${money(order.discount)}"),
        if (order.deliveryFee != null)
          line("Delivery Fee".tr(), "+ ${money(order.deliveryFee)}"),
        line(
          "Tax (%s)".tr().fill(["${order.taxRate ?? 0}%"]),
          "+ ${money(order.tax)}",
        ),
        ...(order.fees ?? []).map(
          (fee) => line("${fee.name}".tr(), "+ ${money(fee.amount)}"),
        ),
        if (order.tip != null && order.tip! > 0)
          line("Driver Tip".tr(), "+ ${money(order.tip)}"),
        Divider(height: 24, color: theme.colorScheme.outlineVariant),
        AmountTile(
          "Total Amount".tr(),
          money(order.total),
          titleStyle: totalStyle,
          amountStyle: totalStyle,
        ),
      ],
    );
  }
}

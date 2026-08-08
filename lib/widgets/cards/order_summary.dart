import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/fee.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Desglose de montos del pedido: líneas de detalle y total destacado.
class OrderSummary extends StatelessWidget {
  const OrderSummary({
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.deliveryDiscount,
    this.tax,
    this.vendorTax,
    this.fees = const [],
    required this.total,
    this.driverTip = 0.00,
    this.mCurrencySymbol,
    this.customWidget,
    this.allowConvert = false,
    this.showTitle = true,
    Key? key,
  }) : super(key: key);

  final double? subTotal;
  final double? discount;
  final double? deliveryFee;
  final double? deliveryDiscount;
  final double? tax;
  final String? vendorTax;
  final double total;
  final double? driverTip;
  final String? mCurrencySymbol;
  final List<Fee> fees;
  final Widget? customWidget;
  final bool allowConvert;

  /// La tarjeta de sección ya muestra un título propio; en ese caso se oculta.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currencySymbol = mCurrencySymbol ?? AppStrings.currentCurrencySymbol;

    /// Formatea un monto con el símbolo y el separador configurados.
    String money(double? amount) =>
        "$currencySymbol ${(amount ?? 0).convertIf(allowConvert)}"
            .currencyFormat(currencySymbol);

    return VStack([
      if (showTitle)
        "Order Summary".tr().text.semiBold.xl.make().pOnly(bottom: Vx.dp12),

      //detalle propio de cada pantalla
      if (customWidget != null) customWidget!,

      _SummaryRow(label: "Subtotal".tr(), amount: money(subTotal)),
      if (discount != null)
        _SummaryRow(
          label: "Discount".tr(),
          amount: "- ${money(discount)}",
          highlight: true,
        ),
      _SummaryRow(
        label: "Tax (%s)".tr().fill(["${vendorTax ?? 0}%"]),
        amount: money(tax),
      ),
      if (deliveryFee != null)
        _SummaryRow(label: "Delivery Fee".tr(), amount: money(deliveryFee)),
      if (deliveryDiscount != null)
        _SummaryRow(
          label: "Delivery Discount".tr(),
          amount: "- ${money(deliveryDiscount)}",
          highlight: true,
        ),

      //cargos configurados por el negocio
      ...fees.map((fee) {
        final isPercentage = fee.percentage == 1;
        return _SummaryRow(
          label:
              isPercentage
                  ? "${fee.name} (%s)".tr().fill(["${fee.value}%"])
                  : "${fee.name}".tr(),
          amount:
              isPercentage
                  ? money(fee.getRate(subTotal ?? 0))
                  : money(fee.value),
        );
      }),

      if (driverTip != null && driverTip! > 0)
        _SummaryRow(label: "Driver Tip".tr(), amount: money(driverTip)),

      //total
      Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: HStack([
          "Total Amount".tr().text.semiBold.make().expand(),
          money(total).text.xl.bold.color(colors.primary).make(),
        ]),
      ),
    ]);
  }
}

/// Línea de monto del desglose.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final String amount;

  /// Los descuentos se marcan en verde para diferenciarlos de los cargos.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return HStack([
      label.text.color(colors.onSurfaceVariant).make().expand(),
      12.widthBox,
      amount.text.medium
          .color(highlight ? Colors.green.shade600 : colors.onSurface)
          .make(),
    ]).py(6);
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/order_product.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/views/pages/order/widgets/order_digitial_product_download.dart';
import 'package:chaskiy/widgets/bottomsheets/order_product_action.bottomsheet.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderProductListItem extends StatelessWidget {
  const OrderProductListItem({
    required this.orderProduct,
    required this.order,
    Key? key,
  }) : super(key: key);

  final OrderProduct orderProduct;
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final quantity = orderProduct.quantity;
    final unitPrice = orderProduct.price;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImage(
          imageUrl: orderProduct.product?.photo,
          width: 60,
          height: 60,
        ).cornerRadius(8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${orderProduct.product?.name}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (orderProduct.options != null &&
                  orderProduct.options!.isNotEmpty)
                Text(
                  orderProduct.options!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mutedStyle,
                ),
              const SizedBox(height: 4),
              //el precio guardado es el de una unidad
              Text("$quantity × ${_money(unitPrice)}", style: mutedStyle),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _money(unitPrice * quantity),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //en comercio se puede volver a pedir o calificar el producto
        order.isCommerce
            ? InkWell(onTap: () => showOrderProductActions(context), child: row)
            : row,
        if (_isDigitalProduct)
          DigitialProductOrderDownload(order, orderProduct).pOnly(top: 10),
      ],
    );
  }

  String _money(double value) =>
      "${AppStrings.currencySymbol}$value".currencyFormat();

  //
  bool get _isDigitalProduct {
    return (order.isCompleted &&
        orderProduct.product != null &&
        orderProduct.product!.isDigital);
  }

  showOrderProductActions(BuildContext context) {
    //show bottomsheet
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return OrderProductActionBottomSheet(orderProduct);
      },
    );
  }
}

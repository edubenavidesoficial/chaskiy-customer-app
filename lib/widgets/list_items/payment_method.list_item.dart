import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentOptionListItem extends StatelessWidget {
  const PaymentOptionListItem(
    this.paymentMethod, {
    this.selected = false,
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  final bool selected;
  final PaymentMethod paymentMethod;
  final Function(PaymentMethod) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.only(left: 8, right: 12),
      decoration: BoxDecoration(
        color:
            selected
                ? colors.primary.withValues(alpha: .10)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: HStack([
        CustomImage(
          imageUrl: paymentMethod.photo,
          width: Vx.dp40,
          height: Vx.dp40,
          boxFit: BoxFit.contain,
        ).py8(),
        10.widthBox,
        paymentMethod.name.tr().text.medium.make().expand(),
        if (selected)
          Icon(
            HugeIcons.strokeRoundedCheckmarkCircle02,
            size: 20,
            color: colors.primary,
          ),
      ]),
    ).onInkTap(() => onSelected(paymentMethod));
  }
}

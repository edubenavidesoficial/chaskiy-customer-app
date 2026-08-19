import 'package:flutter/material.dart';
import 'package:chaskiy/models/order.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TaxiOrderTripVerificationView extends StatelessWidget {
  const TaxiOrderTripVerificationView(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(Icons.pin_outlined, color: theme.colorScheme.primary, size: 25),
        const SizedBox(height: 6),
        Text(
          'Código de verificación'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${order.verificationCode}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

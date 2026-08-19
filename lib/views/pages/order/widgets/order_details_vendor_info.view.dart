import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/buttons/contact_icon_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderDetailsVendorInfoView extends StatelessWidget {
  const OrderDetailsVendorInfoView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCall = vm.order.canChatVendor && AppUISettings.canCallVendor;
    final canChat = vm.order.canChatVendor && AppUISettings.canVendorChat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                vm.order.vendor?.name ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canCall)
              ContactIconButton(
                icon: FlutterIcons.phone_call_fea,
                onPressed: vm.callVendor,
              ),
            if (canChat) ...[
              const SizedBox(width: 8),
              ContactIconButton(
                icon: FlutterIcons.chat_ent,
                onPressed: vm.chatVendor,
              ),
            ],
          ],
        ),

        if (vm.order.canRateVendor) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: vm.rateVendor,
              icon: const Icon(FlutterIcons.rate_review_mdi, size: 18),
              label: Text(
                "Rate %s".tr().fill([
                  (!vm.order.isSerice ? "Vendor" : "Service Provider").tr(),
                ]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

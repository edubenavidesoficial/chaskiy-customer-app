import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/buttons/contact_icon_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderDetailsDriverInfoView extends StatelessWidget {
  const OrderDetailsDriverInfoView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.order.driver == null) return UiSpacer.emptySpace();

    final theme = Theme.of(context);
    final canCall = vm.order.canChatDriver && AppUISettings.canCallDriver;
    final canChat = vm.order.canChatDriver && AppUISettings.canDriverChat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "${vm.order.driver?.name}",
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
                onPressed: vm.callDriver,
              ),
            if (canChat) ...[
              const SizedBox(width: 8),
              ContactIconButton(
                icon: FlutterIcons.chat_ent,
                onPressed: vm.chatDriver,
              ),
            ],
          ],
        ),

        if (vm.order.canRateDriver) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: vm.rateDriver,
              icon: const Icon(FlutterIcons.rate_review_mdi, size: 18),
              label: Text("Rate The Driver".tr()),
            ),
          ),
        ],
      ],
    );
  }
}

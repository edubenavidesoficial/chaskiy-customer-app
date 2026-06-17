import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/views/pages/notification/notifications.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WelcomeSimpleHeaderSection extends StatelessWidget {
  const WelcomeSimpleHeaderSection(
    this.vm, {
    Key? key,
  }) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    Color themeTextColor = Utils.textColorByTheme();
    return VStack(
      [
        HStack(
          [
            Icon(
              FlutterIcons.location_pin_ent,
              size: 24,
              color: themeTextColor,
            ),
            VStack(
              [
                "Deliver To"
                    .tr()
                    .text
                    .thin
                    .light
                    .color(themeTextColor)
                    .sm
                    .make(),
                StreamBuilder<DeliveryAddress?>(
                  stream: LocationService.currenctDeliveryAddressSubject,
                  initialData: vm.deliveryaddress,
                  builder: (conxt, snapshot) {
                    return "${snapshot.data?.address ?? ""}"
                        .text
                        .maxLines(1)
                        .ellipsis
                        .color(themeTextColor)
                        .base
                        .make();
                  },
                ).flexible(),
              ],
            ).flexible(flex: 2),
            Icon(
              FlutterIcons.chevron_down_ent,
              size: 20,
              color: themeTextColor,
            ),
            //
            Spacer(),
            Icon(
              FlutterIcons.bell_fea,
              size: 20,
              color: themeTextColor,
            ).onInkTap(
              () {
                context.nextPage(NotificationsPage());
              },
            ),
          ],
          spacing: 6,
        ).px20().onTap(
          () async {
            await onLocationSelectorPressed();
          },
        ),
        Divider(
          color: themeTextColor.withOpacity(0.45),
          height: 1,
          thickness: 0.5,
        ).wFull(context),
      ],
      spacing: 15,
    ).py20();
  }

  Future<void> onLocationSelectorPressed() async {
    try {
      vm.pickDeliveryAddress(onselected: () {
        vm.pageKey = GlobalKey<State>();
        vm.notifyListeners();
      });
    } catch (error) {
      AlertService.stopLoading();
    }
  }
}

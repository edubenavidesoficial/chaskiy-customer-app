import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({
    Key? key,
    required this.onResult,
  }) : super(key: key);

  //
  final Function(bool) onResult;

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: VStack(
        [
          //title
          "Solicitud de permiso de ubicación".tr().text.semiBold.xl.make().py12(),
          "Gracias por usar %s. Para ofrecerte una mejor experiencia, la app necesita acceder a tu ubicación. Usamos estos datos para mostrarte comercios cercanos, configurar direcciones de entrega durante el pago y permitir el seguimiento en vivo de tu pedido y repartidor. Tu privacidad es importante para nosotros y nunca compartiremos tu ubicación con terceros."
              .tr()
              .fill([AppStrings.appName])
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: () {
              onResult(true);
              AppService().navigatorKey.currentContext?.pop();
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                onResult(false);
                AppService().navigatorKey.currentContext?.pop();
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}

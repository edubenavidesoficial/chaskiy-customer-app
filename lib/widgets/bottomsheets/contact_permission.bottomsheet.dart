import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class ContactPermissionDialog extends StatelessWidget {
  const ContactPermissionDialog({Key? key}) : super(key: key);

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Solicitud de permiso para contactos".tr().text.semiBold.xl.make().py12(),
          ("${AppStrings.appName} " +
                  "usa tu información de contactos para completar automáticamente los datos del destinatario al realizar pedidos. Solo accedemos a tu lista de contactos para sugerir información del destinatario y agilizar el proceso."
                      .tr())
              .text
              .make(),

          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Solicitar permiso".tr(),
            onPressed: () {
              AppService().navigatorKey.currentContext?.pop(true);
            },
          ).py12(),
          CustomButton(
            title: "Cancel".tr(),
            color: Colors.grey[400],
            onPressed: () {
              AppService().navigatorKey.currentContext?.pop(false);
            },
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}

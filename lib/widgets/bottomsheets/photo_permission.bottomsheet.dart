import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class PhotoPermissionDialog extends StatelessWidget {
  const PhotoPermissionDialog({Key? key}) : super(key: key);

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Solicitud de permiso para fotos".tr().text.semiBold.xl.make().py12(),
          ("${AppStrings.appName} " +
                  "necesita tu permiso para acceder a tus fotos, seleccionar una imagen de perfil o subir fotos del pedido."
                      .tr() +
                  "\n\n" +
                  "Sabemos que tu privacidad es importante y no usaremos tus fotos para ningún otro propósito."
                      .tr() +
                  "\n" +
                  "Puedes cambiar este permiso en la configuración de tu dispositivo."
                      .tr())
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: Platform.isIOS ? "Siguiente" : "Solicitar permiso".tr(),
            onPressed: () {
              AppService().navigatorKey.currentContext?.pop(true);
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                AppService().navigatorKey.currentContext?.pop(false);
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}

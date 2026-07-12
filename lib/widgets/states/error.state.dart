import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class LoadingError extends StatelessWidget {
  const LoadingError({
    this.onrefresh,
    Key? key,
  }) : super(key: key);

  final Function? onrefresh;
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.error,
      showAction: true,
      actionPressed: onrefresh,
      actionText: "Retry".tr(),
      title: "Ocurrió un error".tr(),
      description:
          "Hubo un error al procesar tu solicitud. Inténtalo nuevamente".tr(),
    ).p20();
  }
}

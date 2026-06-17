import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/view_models/splash.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          return VStack(
            [
              //
              Image.asset(AppImages.appLogo)
                  .wh(context.percentWidth * 45, context.percentWidth * 45)
                  .box
                  .clip(Clip.antiAlias)
                  .roundedSM
                  .makeCentered()
                  .py12(),
              //linear progress indicator
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.primaryColor,
                ),
              ).wOneThird(context).centered(),
            ],
            crossAlignment: CrossAxisAlignment.center,
            alignment: MainAxisAlignment.center,
          ).centered();
        },
      ),
    );
  }
}

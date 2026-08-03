import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/sizes.dart';
import 'package:chaskiy/enums/app_role.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/login.view_model.dart';
import 'package:chaskiy/views/pages/auth/login/compain_login_type.view.dart';
import 'package:chaskiy/views/pages/auth/login/email_login.view.dart';
import 'package:chaskiy/views/pages/auth/login/otp_login.view.dart';
import 'package:chaskiy/views/pages/auth/login/social_media.view.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/buttons/arrow_indicator.dart';
import 'package:chaskiy/widgets/dynamic_status_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    this.required = false,
    this.expectedRole = AppRole.customer,
    Key? key,
  }) : super(key: key);

  final bool required;
  final AppRole expectedRole;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: context.backgroundColor,
      child: ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(
          context,
          expectedRole: widget.expectedRole,
        ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return PopScope(
            canPop: !widget.required,
            onPopInvoked: (didPop) async {
              if (!didPop && widget.required) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "You are required to login/register to continue process"
                          .tr(),
                    ),
                  ),
                );
              }
            },
            child: BasePage(
              showLeadingAction: !widget.required,
              showAppBar: !widget.required,
              appBarColor: AppColor.faintBgColor,
              leading: IconButton(
                icon: ArrowIndicator(leading: true),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 0,
              isLoading: model.isBusy,
              body: SafeArea(
                top: true,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: context.mq.viewInsets.bottom,
                  ),
                  child:
                      VStack([
                        //
                        VStack([
                          //
                          HStack([
                            VStack([
                              (widget.expectedRole == AppRole.driver
                                      ? "Acceso para conductores"
                                      : "Welcome Back".tr())
                                  .text
                                  .xl2
                                  .semiBold
                                  .make(),
                              (widget.expectedRole == AppRole.driver
                                      ? "Conductor o motorizado"
                                      : "Login to continue".tr())
                                  .text
                                  .light
                                  .make(),
                            ]).expand(),
                            Image.asset(AppImages.appLogo)
                                .h(60)
                                .w(60)
                                .box
                                .withRounded(value: Sizes.radiusSmall)
                                .clip(Clip.antiAlias)
                                .make(),
                          ]),

                          //LOGIN Section
                          //both login type
                          if (AppStrings.enableOTPLogin &&
                              AppStrings.enableEmailLogin)
                            CombinedLoginTypeView(
                              model,
                              radius: Sizes.radiusLarge,
                            ),
                          //only email login
                          if (AppStrings.enableEmailLogin &&
                              !AppStrings.enableOTPLogin)
                            EmailLoginView(model),
                          //only otp login
                          if (AppStrings.enableOTPLogin &&
                              !AppStrings.enableEmailLogin)
                            OTPLoginView(model),
                        ]).wFull(context).px20().pOnly(top: Vx.dp20),
                        //
                        //register
                        if (widget.expectedRole == AppRole.customer)
                          HStack([
                            UiSpacer.divider().expand(),
                            "OR".tr().text.light.make().px8(),
                            UiSpacer.divider().expand(),
                          ]).py8().px20(),
                        if (widget.expectedRole == AppRole.customer)
                          "New user?".tr().richText
                            .withTextSpanChildren([
                              " ".textSpan.make(),
                              "Create An Account"
                                  .tr()
                                  .textSpan
                                  .semiBold
                                  .color(AppColor.primaryColor)
                                  .make(),
                            ])
                            .makeCentered()
                            .py12()
                              .onInkTap(model.openRegister),
                        if (widget.expectedRole == AppRole.customer)
                          SocialMediaView(model, bottomPadding: 10),
                        ScanLoginView(model),
                        if (widget.expectedRole == AppRole.customer)
                          VStack([
                            _DriverAccessCard(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LoginPage(
                                    expectedRole: AppRole.driver,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _VendorAccessCard(
                              onTap: () => _openVendorLogin(context),
                            ),
                          ]).px20().py16(),
                      ]).scrollVertical(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openVendorLogin(BuildContext context) async {
    final opened = await launchUrlString(
      'https://app.chaskiy.com/login',
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el acceso de vendedor')),
      );
    }
  }
}

class _DriverAccessCard extends StatelessWidget {
  const _DriverAccessCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColor.primaryColor.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        side: BorderSide(
          color: AppColor.primaryColor.withValues(alpha: .18),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.delivery_dining),
        ),
        title: const Text(
          "¿Trabajas con Chaskiy?",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text("Inicia sesión como conductor o motorizado"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}

class _VendorAccessCard extends StatelessWidget {
  const _VendorAccessCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColor.primaryColor.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        side: BorderSide(
          color: AppColor.primaryColor.withValues(alpha: .18),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.storefront_outlined),
        ),
        title: const Text(
          'Iniciar sesión como vendedor',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Accede al portal de vendedores'),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      ),
    );
  }
}

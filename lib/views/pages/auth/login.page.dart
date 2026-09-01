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
  LoginPage({this.required = false, Key? key}) : super(key: key);

  final bool required;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: context.backgroundColor,
      child: ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(context),
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
                child:
                    VStack([
                      //
                      VStack([
                        //
                        HStack([
                          VStack([
                            "Bienvenido a Chaskiy".text.xl2.semiBold.make(),
                            "Ingresa como cliente o conductor".text.light
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
                      HStack([
                        UiSpacer.divider().expand(),
                        "OR".tr().text.light.make().px8(),
                        UiSpacer.divider().expand(),
                      ]).py8().px20(),
                      _RegistrationOptions(
                        onCustomer: () => model.openRegister(AppRole.customer),
                        onDriver: () => model.openRegister(AppRole.driver),
                      ).px20().py8(),
                      SocialMediaView(model, bottomPadding: 10),
                      ScanLoginView(model),
                      _VendorAccessCard(
                        onTap: () => _openVendorLogin(context),
                      ).px20().py16(),
                    ]).scrollVertical(),
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

class _RegistrationOptions extends StatelessWidget {
  const _RegistrationOptions({
    required this.onCustomer,
    required this.onDriver,
  });

  final VoidCallback onCustomer;
  final VoidCallback onDriver;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('¿Eres nuevo?'),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onCustomer,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Crear cuenta cliente'),
            ),
            OutlinedButton.icon(
              onPressed: onDriver,
              icon: const Icon(Icons.delivery_dining_rounded, size: 18),
              label: const Text('Crear cuenta conductor'),
            ),
          ],
        ),
      ],
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
        side: BorderSide(color: AppColor.primaryColor.withValues(alpha: .18)),
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

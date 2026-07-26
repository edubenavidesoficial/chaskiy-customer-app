import 'package:chaskiy/services/validator.service.dart';
import 'package:chaskiy/view_models/change_password.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:chaskiy/widgets/forms/account_form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(context),
      builder:
          (context, model, child) => AccountFormScaffold(
            title: 'Cambiar contraseña',
            description:
                'Usa una contraseña segura que no utilices en otras cuentas.',
            icon: Icons.lock_reset_rounded,
            child: Form(
              key: model.formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    labelText: 'Contraseña actual',
                    obscureText: true,
                    textEditingController: model.currentPasswordTEC,
                    validator: FormValidator.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CustomTextFormField(
                    labelText: 'Nueva contraseña',
                    obscureText: true,
                    textEditingController: model.newPasswordTEC,
                    validator: FormValidator.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CustomTextFormField(
                    labelText: 'Confirmar nueva contraseña',
                    obscureText: true,
                    textEditingController: model.confirmNewPasswordTEC,
                    validator: FormValidator.validatePassword,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: 'Guardar contraseña',
                      icon: Icons.check_rounded,
                      loading: model.isBusy,
                      onPressed: model.processUpdate,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

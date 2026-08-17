import 'package:flutter/material.dart';
import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'base.view_model.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  final TextEditingController emailTEC = TextEditingController();
  final AuthRequest _authRequest = AuthRequest();

  ForgotPasswordViewModel(BuildContext context) {
    viewContext = context;
  }

  Future<void> processForgotPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setBusy(true);
    try {
      final response = await _authRequest.sendPasswordResetEmail(emailTEC.text);
      AlertService.dynamic(
        type: response.allGood ? AlertType.success : AlertType.error,
        title: "Forgot Password".tr(),
        text: response.message,
        onConfirm: response.allGood ? () => Navigator.of(viewContext).pop() : null,
      );
    } catch (error) {
      AlertService.error(
        title: "Forgot Password".tr(),
        text: "We could not send the password reset email. Please try again.".tr(),
      );
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    emailTEC.dispose();
    super.dispose();
  }
}

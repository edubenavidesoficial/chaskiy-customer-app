import 'package:flutter/material.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:chaskiy/extensions/context.dart';

class ChangePasswordViewModel extends MyBaseViewModel {
  User? currentUser;
  //the textediting controllers
  TextEditingController currentPasswordTEC = new TextEditingController();
  TextEditingController newPasswordTEC = new TextEditingController();
  TextEditingController confirmNewPasswordTEC = new TextEditingController();

  //
  AuthRequest _authRequest = AuthRequest();

  ChangePasswordViewModel(BuildContext context) {
    this.viewContext = context;
  }

  @override
  void dispose() {
    currentPasswordTEC.dispose();
    newPasswordTEC.dispose();
    confirmNewPasswordTEC.dispose();
    super.dispose();
  }

  //
  processUpdate() async {
    //
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);

      //
      final apiResponse = await _authRequest.updatePassword(
        password: currentPasswordTEC.text,
        new_password: newPasswordTEC.text,
        new_password_confirmation: confirmNewPasswordTEC.text,
      );

      //
      setBusy(false);

      //
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Change Password".tr(),
        text: apiResponse.message,
        onConfirm:
            apiResponse.allGood
                ? () {
                  viewContext.pop(true);
                }
                : null,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';

class InputStyles {
  //get the border for the textform field
  static InputBorder inputEnabledBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(16),
    );
  }

  //get the border for the textform field
  static InputBorder inputFocusBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColor, width: 1.6),
      borderRadius: BorderRadius.circular(16),
    );
  }

  //
  //get the border for the textform field
  static InputBorder inputUnderlineEnabledBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColor),
      borderRadius: BorderRadius.circular(16),
    );
  }

  //get the border for the textform field
  static InputBorder inputUnderlineFocusBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColorDark),
      borderRadius: BorderRadius.circular(16),
    );
  }
}

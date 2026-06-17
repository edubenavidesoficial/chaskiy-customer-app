import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/delivery_address/base_delivery_addresses.vm.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class What3wordsView extends StatelessWidget {
  const What3wordsView(this.vm, {Key? key}) : super(key: key);
  final BaseDeliveryAddressesViewModel vm;
  @override
  Widget build(BuildContext context) {
    return (AppStrings.isWhat3wordsApiKey
            ? VStack(
                [
                  CustomTextFormField(
                    labelText: "What3words " + "Name".tr(),
                    textEditingController: vm.what3wordsTEC,
                    onFieldSubmitted: vm.validateWhat3words,
                  ),
                  //
                  "Get What3words name from this link"
                      .tr()
                      .text
                      .sm
                      .underline
                      .make()
                      .py2()
                      .onInkTap(vm.shareWhat3words),
                ],
              )
            : UiSpacer.emptySpace())
        .py16();
  }
}

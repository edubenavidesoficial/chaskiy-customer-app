import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class UploadPrescriptionFab extends StatelessWidget {
  const UploadPrescriptionFab(this.model, {Key? key}) : super(key: key);

  final VendorDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return model.vendor!.isPharmacyType && AppStrings.enableUploadPrescription
        ? FloatingActionButton.extended(
          onPressed: model.uploadPrescription,
          backgroundColor: AppColor.primaryColor,
          label:
              "Upload Prescription"
                  .tr()
                  .tr()
                  .text
                  .color(Utils.textColorByPrimaryColor())
                  .make(),
          icon: Icon(
            FlutterIcons.pills_faw5s,
            color: Utils.textColorByPrimaryColor(),
            size: 22,
          ),
          extendedIconLabelSpacing: 20,
        )
        : UiSpacer.emptySpace();
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ViewAllVendorsView extends StatelessWidget {
  const ViewAllVendorsView({Key? key, required this.vendorType})
    : super(key: key);
  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    final singleVendor = AppStrings.enableSingleVendor;

    final String label;
    final Search search;
    if (!singleVendor) {
      label = "View all vendors".tr();
      search = Search(
        vendorType: vendorType,
        byLocation: false,
        showProductsTag: false,
        showVendorsTag: !vendorType.isService,
        showServicesTag: false,
        showProvidesTag: vendorType.isService,
        type: "vendor",
      );
    } else {
      label =
          !vendorType.isService
              ? "View all products".tr()
              : "View all services".tr();
      search = Search(
        vendorType: vendorType,
        byLocation: false,
        showProductsTag: !vendorType.isService,
        showVendorsTag: !vendorType.isService,
        showProvidesTag: vendorType.isService,
        showServicesTag: vendorType.isService,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed:
              () => Navigator.pushNamed(
                context,
                AppRoutes.search,
                arguments: search,
              ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Utils.textColorByPrimaryColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          icon: Icon(
            Utils.isArabic
                ? Icons.arrow_back_rounded
                : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

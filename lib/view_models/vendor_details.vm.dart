import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/requests/vendor.request.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/views/pages/pharmacy/pharmacy_upload_prescription.page.dart';
import 'package:chaskiy/views/pages/vendor_search/vendor_search.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:chaskiy/extensions/context.dart';

class VendorDetailsViewModel extends MyBaseViewModel {
  //
  VendorDetailsViewModel(BuildContext context, this.vendor) {
    this.viewContext = context;
  }

  //
  VendorRequest _vendorRequest = VendorRequest();

  //
  Vendor? vendor;
  TabController? tabBarController;
  final currencySymbol = AppStrings.currencySymbol;

  RefreshController refreshContoller = RefreshController();
  List<RefreshController> refreshContollers = [];
  List<int> refreshContollerKeys = [];

  //
  Map<int, List<Product>> menuProducts = {};
  Map<int, int> menuProductsQueryPages = {};

  //
  getVendorDetails() async {
    //
    setBusy(true);

    try {
      vendor = await _vendorRequest.vendorDetails(
        vendor!.id,
        params: {"type": "small"},
        forceRefresh: true,
      );

      clearErrors();
    } catch (error) {
      setError(error);
      print("error ==> ${error}");
    }
    setBusy(false);
  }

  void productSelected(Product product) async {
    await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.product, arguments: product);

    //
    notifyListeners();
  }

  //
  void uploadPrescription() {
    //
    viewContext.push((context) => PharmacyUploadPrescription(vendor!));
  }

  openVendorSearch() {
    viewContext.push((context) => VendorSearchPage(vendor!));
  }
}

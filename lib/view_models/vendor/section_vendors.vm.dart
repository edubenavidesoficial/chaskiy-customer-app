import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/vendor.request.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/services/app.service.dart';

class SectionVendorsViewModel extends MyBaseViewModel {
  SectionVendorsViewModel(
    BuildContext context,
    this.vendorType, {
    this.type = SearchFilterType.you,
    this.byLocation = false,
  }) {
    this.viewContext = context;
  }

  //
  List<Vendor> vendors = [];
  VendorType? vendorType;
  SearchFilterType type;
  bool? byLocation;
  VendorRequest _vendorRequest = VendorRequest();
  StreamSubscription<bool>? _refreshSubscription;

  //
  initialise() {
    fetchVendors();
    _refreshSubscription ??= AppService().refreshHomeContent.listen(
      (_) => fetchVendors(silent: true),
    );
  }

  //
  fetchVendors({bool silent = false}) async {
    if (!silent && vendors.isEmpty) setBusy(true);
    try {
      //filter by location if user selects delivery address
      vendors = await _vendorRequest.vendorsRequest(
        byLocation: byLocation ?? true,
        params: {"vendor_type_id": vendorType?.id, "type": type.name},
      );

      clearErrors();
    } catch (error) {
      print("error loading vendors ==> $error");
      setError(error);
    }
    if (!silent && isBusy) setBusy(false);
    if (silent) notifyListeners();
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  vendorSelected(Vendor vendor) async {
    Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.vendorDetails, arguments: vendor);
  }
}

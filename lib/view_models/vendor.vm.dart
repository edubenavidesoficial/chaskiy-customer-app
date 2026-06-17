import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class VendorViewModel extends MyBaseViewModel {
  //
  VendorViewModel(BuildContext context, VendorType vendorType) {
    this.viewContext = context;
    this.vendorType = vendorType;
  }
  //
  User? currentUser;
  StreamSubscription? currentLocationChangeStream;

  //
  int queryPage = 1;

  RefreshController refreshController = RefreshController();

  void initialise() async {
    preloadDeliveryLocation();
    //
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }
  }

  //switch to use current location instead of selected delivery address
  void useUserLocation() {
    LocationService.geocodeCurrentLocation();
  }

  //
  dispose() {
    super.dispose();
    currentLocationChangeStream?.cancel();
  }
}

import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/enums/product_fetch_data_type.enum.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/product.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/services/app.service.dart';

class ProductsViewModel extends MyBaseViewModel {
  //
  ProductsViewModel(
    BuildContext context,
    this.vendorType,
    this.type, {
    this.categoryId,
    this.byLocation,
  }) {
    this.viewContext = context;
    if (this.byLocation == null) {
      this.byLocation = AppStrings.enableFatchByLocation;
    }
  }

  //
  User? currentUser;

  //
  VendorType? vendorType;
  int? categoryId;
  ProductFetchDataType type;
  ProductRequest productRequest = ProductRequest();
  List<Product> products = [];
  late bool? byLocation;
  StreamSubscription<bool>? _refreshSubscription;

  bool get anyProductWithOptions {
    try {
      return products.firstOrNullWhere(
            (e) =>
                e.optionGroups.isNotEmpty &&
                e.optionGroups.first.options.isNotEmpty,
          ) !=
          null;
    } catch (error) {
      return false;
    }
  }

  void initialise() async {
    //
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }

    deliveryaddress?.address = LocationService.currenctAddress?.addressLine;
    deliveryaddress?.latitude =
        LocationService.currenctAddress?.coordinates?.latitude;
    deliveryaddress?.longitude =
        LocationService.currenctAddress?.coordinates?.longitude;

    //get today picks
    fetchProducts();
    _refreshSubscription ??= AppService().refreshHomeContent.listen(
      (_) => fetchProducts(silent: true),
    );
  }

  //
  fetchProducts({bool silent = false}) async {
    //
    if (!silent && products.isEmpty) setBusy(true);
    try {
      Map<String, dynamic> queryParams = {
        "category_id": categoryId,
        "vendor_type_id": vendorType?.id,
        "type": type.name.toLowerCase(),
      };

      if ((byLocation != null && byLocation!) &&
          deliveryaddress?.latitude != null) {
        queryParams.addAll({
          "latitude": deliveryaddress?.latitude,
          "longitude": deliveryaddress?.longitude,
        });
      }

      products = await productRequest.getProdcuts(queryParams: queryParams);
    } catch (error) {
      print("fetchProducts Error ==> $error");
    }
    if (!silent && isBusy) setBusy(false);
    if (silent) notifyListeners();
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }
}

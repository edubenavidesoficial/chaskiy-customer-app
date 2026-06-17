import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/product.request.dart';
import 'package:chaskiy/view_models/base.view_model.dart';

class ForYouProductsViewModel extends MyBaseViewModel {
  //
  ProductRequest _productRequest = ProductRequest();
  //
  List<Product> products = [];
  VendorType? vendorType;

  ForYouProductsViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //
  initialise() async {
    setBusy(true);
    try {
      products = await _productRequest.forYouProductsRequest(
        queryParams: {
          "vendor_type_id": vendorType?.id,
        },
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  productSelected(Product product) async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.product,
      arguments: product,
    );
  }
}

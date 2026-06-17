import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/property.dart';
import 'package:chaskiy/requests/property.request.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';

class PropertyVendorDetailsViewModel extends VendorDetailsViewModel {
  PropertyVendorDetailsViewModel(BuildContext context, Vendor vendor)
    : super(context, vendor);

  final PropertyRequest _propertyRequest = PropertyRequest();
  List<Property> properties = [];
  int page = 1;

  void initialise() {
    getVendorDetails();
    fetchVendorProperties();
  }

  Future<void> fetchVendorProperties([bool initialLoad = true]) async {
    refreshController.refreshCompleted();
    if (initialLoad) {
      page = 1;
      properties.clear();
    } else {
      page++;
    }

    List<Property> newProperties = [];
    setBusy(true);
    try {
      newProperties = await _propertyRequest.getProperties(
        queryParams: {"vendor_id": vendor!.id, "page": page},
      );

      newProperties.forEach((property) {
        property.vendor = vendor;
      });
      properties.addAll(newProperties);
    } catch (error) {
      setError(error);
    }
    refreshController.loadComplete();
    if (newProperties.isEmpty) {
      refreshController.loadNoData();
    }
    setBusy(false);
  }
}

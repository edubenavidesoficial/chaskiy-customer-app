import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/service.request.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/views/pages/service/service_details.page.dart';
import 'package:chaskiy/extensions/context.dart';

class PopularServicesViewModel extends MyBaseViewModel {
  //
  ServiceRequest _serviceRequest = ServiceRequest();
  //
  List<Service> services = [];
  VendorType? vendorType;

  PopularServicesViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //
  initialise() async {
    setBusy(true);
    try {
      services = await _serviceRequest.getServices(
        byLocation: AppStrings.enableFatchByLocation,
        queryParams: {
          "vendor_type_id": vendorType?.id,
        },
      );
      clearErrors();
    } catch (error) {
      print("PopularServicesViewModel Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  //
  serviceSelected(Service service) {
    viewContext.push(
      (context) => ServiceDetailsPage(service),
    );
  }

  openSearch({int showType = 4}) async {
    NavigationService.openServiceSearch(
      viewContext,
      byLocation: AppStrings.enableFatchByLocation,
      vendorType: vendorType,
      showServices: true,
      showVendors: false,
    );
  }
}

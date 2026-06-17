import 'package:flutter/material.dart' hide Banner;
import 'package:chaskiy/models/banner.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/banner.request.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/search.dart';
import 'package:velocity_x/velocity_x.dart';

class BannersViewModel extends MyBaseViewModel {
  BannersViewModel(
    BuildContext context,
    this.vendorType, {
    this.featured = false,
    this.onEmpty,
  }) {
    this.viewContext = context;
  }
  //
  BannerRequest _bannerRequest = BannerRequest();
  bool featured;
  VendorType? vendorType;
  Function()? onEmpty;
  //
  List<Banner> banners = [];
  int currentIndex = 0;

  //
  initialise() async {
    setBusy(true);
    try {
      banners = await _bannerRequest.banners(
        vendorTypeId: vendorType?.id,
        params: {"featured": featured ? "1" : "0"},
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);

    if (banners.isEmpty) {
      onEmpty?.call();
    }
  }

  //
  bannerSelected(Banner banner) {
    if (banner.link != null && banner.link.isNotEmptyAndNotNull) {
      openWebpageLink(banner.link!);
    } else if (banner.vendor != null) {
      Navigator.of(
        viewContext,
      ).pushNamed(AppRoutes.vendorDetails, arguments: banner.vendor);
    } else {
      Navigator.of(viewContext).pushNamed(
        AppRoutes.search,
        arguments: Search(category: banner.category, byLocation: false),
      );
    }
  }
}

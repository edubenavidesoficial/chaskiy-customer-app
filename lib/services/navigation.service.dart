import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/views/pages/auth/login.page.dart';
import 'package:chaskiy/views/pages/booking/booking.page.dart';
import 'package:chaskiy/views/pages/category/categories.page.dart';
import 'package:chaskiy/views/pages/category/subcategories.page.dart';
import 'package:chaskiy/views/pages/commerce/commerce.page.dart';
import 'package:chaskiy/views/pages/food/food.page.dart';
import 'package:chaskiy/views/pages/grocery/grocery.page.dart';
import 'package:chaskiy/views/pages/parcel/parcel.page.dart';
import 'package:chaskiy/views/pages/pharmacy/pharmacy.page.dart';
import 'package:chaskiy/views/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:chaskiy/views/pages/product/product_details.page.dart';
import 'package:chaskiy/views/pages/search/product_search.page.dart';
import 'package:chaskiy/views/pages/search/search.page.dart';
import 'package:chaskiy/views/pages/search/service_search.page.dart';
import 'package:chaskiy/views/pages/service/custom_service.page.dart';
// import 'package:chaskiy/views/pages/service/service.page.dart';
import 'package:chaskiy/views/pages/taxi/taxi.page.dart';
import 'package:chaskiy/views/pages/vendor/vendor.page.dart';
import 'package:chaskiy/views/pages/vendor_details/vendor_details.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class NavigationService {
  static pageSelected(
    VendorType vendorType, {
    required BuildContext context,
    bool loadNext = true,
  }) async {
    Widget nextpage = vendorTypePage(vendorType, context: context);

    //
    if (vendorType.authRequired && !AuthServices.authenticated()) {
      final result = await context.push(
        (context) => LoginPage(required: false),
      );
      //
      if (result == null || !result) {
        return;
      }
    }
    //
    if (loadNext) {
      context.nextPage(nextpage);
    }
  }

  static Widget vendorTypePage(
    VendorType vendorType, {
    required BuildContext context,
  }) {
    Widget homeView = VendorPage(vendorType);
    switch (vendorType.slug) {
      case "parcel":
        homeView = ParcelPage(vendorType);
        break;
      case "grocery":
        homeView = GroceryPage(vendorType);
        break;
      case "food":
        homeView = FoodPage(vendorType);
        break;
      case "pharmacy":
        homeView = PharmacyPage(vendorType);
        break;
      case "service":
        // homeView = ServicePage(vendorType);
        homeView = ServicesPage(vendorType);
        break;
      case "booking":
        homeView = BookingPage(vendorType);
        break;
      case "taxi":
        homeView = TaxiPage(vendorType);
        break;
      case "commerce":
        homeView = CommercePage(vendorType);
        break;
      default:
        homeView = VendorPage(vendorType);
        break;
    }
    return homeView;
  }

  ///special for product page
  Widget productDetailsPageWidget(Product product) {
    if (!product.vendor.vendorType.isCommerce) {
      return ProductDetailsPage(product: product);
    } else {
      return AmazonStyledCommerceProductDetailsPage(product: product);
    }
  }

  //
  Widget searchPageWidget(Search search) {
    if (search.vendorType == null) {
      return SearchPage(search: search);
    }
    //
    if (search.vendorType!.isProduct) {
      return ProductSearchPage(search: search);
    } else if (search.vendorType!.isService) {
      return ServiceSearchPage(
        category: search.category,
        subcategory: search.subcategory,
        vendorType: search.vendorType,
        byLocation: search.byLocation ?? true,
        showVendors: search.showProvidesTag || search.showProvidesTag,
        showServices: search.showServicesTag,
        // showVendors: search.showVendors(),
        // showServices: search.showServices(),
      );
    } else {
      return SearchPage(search: search);
    }
  }

  //open service search
  static openServiceSearch(
    BuildContext context, {
    Category? category,
    VendorType? vendorType,
    bool showVendors = true,
    bool showServices = true,
    bool byLocation = true,
  }) {
    context.nextPage(
      ServiceSearchPage(
        category: category,
        vendorType: vendorType,
        showVendors: showVendors,
        showServices: showServices,
        byLocation: byLocation,
      ),
    );
  }

  static openVendorDetailsPage(Vendor vendor, {required BuildContext context}) {
    context.nextPage(VendorDetailsPage(vendor: vendor));
  }

  static void openCategoriesPage({VendorType? vendorType}) {
    AppService().navigatorKey.currentContext!.nextPage(
      CategoriesPage(vendorType: vendorType),
    );
  }

  static categorySelected(Category category) async {
    AppService().navigatorKey.currentContext!.nextPage(
      SubcategoriesPage(category: category),
    );
  }

  static void openServiceDetails(Service service) {
    Navigator.of(
      AppService().navigatorKey.currentContext!,
    ).pushNamed(AppRoutes.serviceDetails, arguments: service);
  }
}

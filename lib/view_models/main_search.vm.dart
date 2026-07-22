import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/requests/search.request.dart';
import 'package:chaskiy/requests/vendor_type.request.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/services/search.service.dart';
import 'package:chaskiy/view_models/search.vm.dart';
import 'package:chaskiy/view_models/search_filter.vm.dart';
import 'package:chaskiy/widgets/bottomsheets/search_filter.bottomsheet.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class MainSearchViewModel extends SearchViewModel {
  //
  SearchRequest _searchRequest = SearchRequest();
  ScrollController scrollController = ScrollController();
  List<RefreshController> refreshControllers = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
  ];

  Category? category;
  VendorType? bookingVendorType;
  //
  int vendorsPage = 1;
  int productsPage = 1;
  int servicesPage = 1;
  bool showVendors = false;
  bool showProducts = false;
  bool showServices = false;
  bool showProperties = false;
  List<Vendor> vendors = [];
  List<Product> products = [];
  List<Service> services = [];
  int selectedIndex = 0;
  bool _searchErrorShown = false;

  MainSearchViewModel(BuildContext context) : super(context, Search());

  initialise() async {
    await fetchSearchHistory();
    await fetchSearchTabs();
    startSearch();
  }

  resetRefreshcontrollers() {
    refreshControllers = [
      RefreshController(),
      RefreshController(),
      RefreshController(),
      RefreshController(),
    ];
  }

  fetchSearchHistory() async {
    searchHistory = await SearchService.getSearchHistory();
    notifyListeners();
  }

  fetchSearchTabs() async {
    setBusy(true);
    try {
      final vendorTypes = await VendorTypeRequest().index();
      for (var vendorType in vendorTypes) {
        if (vendorType.isService) {
          showServices = true;
        } else if (vendorType.isProduct) {
          showProducts = true;
        } else if (vendorType.isBooking) {
          showProperties = true;
          bookingVendorType = vendorType;
        }
      }

      showVendors = showServices || showProducts;
    } catch (error) {
      _showSearchError(error);
    }
    setBusy(false);
  }

  // onTabChange(int index) {
  //   selectedIndex = index;
  //   notifyListeners();
  //   if (index == 0 && (vendors.isEmpty)) {
  //     searchVendors();
  //   } else if (index == 1 && (products.isEmpty)) {
  //     searchProducts();
  //   } else if (index == 2 && (services.isEmpty)) {
  //     searchServices();
  //   }
  // }

  //
  startSearch({bool initialLoaoding = true}) async {
    _searchErrorShown = false;
    if (showProducts) {
      searchProducts(initial: initialLoaoding);
    }
    if (showVendors) {
      searchVendors(initial: initialLoaoding);
    }
    if (showServices) {
      searchServices(initial: initialLoaoding);
    }
    // if (selectedIndex == 0) {
    //   searchVendors(initial: initialLoaoding);
    // } else if (selectedIndex == 1) {
    //   searchProducts(initial: initialLoaoding);
    // } else {
    //   searchServices(initial: initialLoaoding);
    // }
  }

  searchVendors({bool initial = true}) async {
    //
    if (initial) {
      setBusyForObject(vendors, true);
      vendorsPage = 1;
      refreshControllers[0].refreshCompleted();
    } else {
      vendorsPage = vendorsPage + 1;
    }

    //
    try {
      List<Vendor> searchResult =
          (await _searchRequest.searchRequest(
            keyword: keyword,
            search: search!,
            type: "vendor",
            page: vendorsPage,
          )).cast<Vendor>();
      clearErrors();

      //
      if (initial) {
        vendors = searchResult;
      } else {
        vendors.addAll(searchResult);
      }
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      _showSearchError(error);
    }

    if (!initial) {
      refreshControllers[0].loadComplete();
    }
    //done loading data
    setBusyForObject(vendors, false);
  }

  searchProducts({bool initial = true}) async {
    //
    if (initial) {
      setBusyForObject(products, true);
      productsPage = 1;
      refreshControllers[1].refreshCompleted();
    } else {
      productsPage = productsPage + 1;
    }

    //
    try {
      List<Product> searchResult =
          (await _searchRequest.searchRequest(
            keyword: keyword,
            search: search!,
            type: "product",
            page: productsPage,
          )).cast<Product>();
      clearErrors();

      //
      if (initial) {
        products = searchResult;
      } else {
        products.addAll(searchResult);
      }
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      _showSearchError(error);
    }

    if (!initial) {
      refreshControllers[1].loadComplete();
    }
    //done loading data
    setBusyForObject(products, false);
  }

  searchServices({bool initial = true}) async {
    //
    if (initial) {
      setBusyForObject(services, true);
      servicesPage = 1;
      refreshControllers.last.refreshCompleted();
    } else {
      servicesPage = servicesPage + 1;
    }

    //
    try {
      List<Service> searchResult =
          (await _searchRequest.searchRequest(
            keyword: keyword,
            search: search!,
            type: "service",
            page: servicesPage,
          )).cast<Service>();
      clearErrors();

      //
      if (initial) {
        services = searchResult;
      } else {
        services.addAll(searchResult);
      }
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      _showSearchError(error);
    }

    if (!initial) {
      refreshControllers.last.loadComplete();
    }
    //done loading data
    setBusyForObject(services, false);
  }

  void _showSearchError(Object error) {
    if (_searchErrorShown) return;
    _searchErrorShown = true;

    final rawMessage = error.toString();
    final isTechnicalError =
        rawMessage.contains("is not a subtype") ||
        rawMessage.contains("NoSuchMethodError") ||
        rawMessage.contains("type '") ||
        rawMessage.contains("Exception:");

    toastError(
      isTechnicalError ? ApiResponse.unavailableMessage : rawMessage,
    );
  }

  //
  void showFilterOptions() async {
    if (searchFilterVM == null) {
      searchFilterVM = SearchFilterViewModel(viewContext, search!);
    }

    refreshController = refreshController = RefreshController();
    notifyListeners();

    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SearchFilterBottomSheet(
          search: search!,
          vm: searchFilterVM!,
          onSubmitted: (mSearch) {
            search = mSearch;
            queryPage = 1;
            //reset refreshcontrollers
            resetRefreshcontrollers();
            startSearch();
          },
        );
      },
    );
  }

  //
  productSelected(Product product) async {
    final page = NavigationService().productDetailsPageWidget(product);
    viewContext.nextPage(page);
  }

  //
  vendorSelected(Vendor vendor) async {
    Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.vendorDetails, arguments: vendor);
  }

  toggleShowGird(bool mShowGrid) {
    showGrid = mShowGrid;
    refreshController = new RefreshController();
    notifyListeners();
  }

  void openPropertySearch() {
    if (bookingVendorType != null) {
      Navigator.pushNamed(
        viewContext,
        AppRoutes.propertySearchRoute,
        arguments: bookingVendorType,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/menu.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/requests/product.request.dart';
import 'package:chaskiy/requests/vendor.request.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/views/pages/pharmacy/pharmacy_upload_prescription.page.dart';
import 'package:chaskiy/views/pages/vendor_search/vendor_search.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:chaskiy/extensions/context.dart';

import 'vendor_details.vm.dart';

class VendorDetailsWithMenuViewModel extends VendorDetailsViewModel {
  //
  VendorDetailsWithMenuViewModel(
    BuildContext context,
    this.vendor, {
    required this.tickerProvider,
  }) : super(context, vendor) {
    this.viewContext = context;
  }

  //
  VendorRequest _vendorRequest = VendorRequest();

  //
  Vendor? vendor;
  TickerProvider? tickerProvider;
  TabController? tabBarController;
  final currencySymbol = AppStrings.currencySymbol;

  ProductRequest _productRequest = ProductRequest();
  RefreshController refreshContoller = RefreshController();
  List<RefreshController> refreshContollers = [];
  List<int> refreshContollerKeys = [];

  //
  Map<int, List<Product>> menuProducts = {};
  Map<int, int> menuProductsQueryPages = {};
  bool _loadingVendor = false;

  //
  Future<void> getVendorDetails() async {
    if (_loadingVendor) return;
    _loadingVendor = true;
    setBusy(true);

    try {
      final updatedVendor = await _vendorRequest.vendorDetails(
        vendor!.id,
        params: {"type": "small"},
        // Evita que Android reutilice una respuesta vacía guardada.
        forceRefresh: true,
      );

      vendor = updatedVendor;
      if (!vendor!.menus.any((menu) => menu.id == 0)) {
        vendor!.menus.insert(0, Menu.fromJson({"id": 0, "name": "Todos"}));
      }
      generateRefreshController();
      updateUiComponents();
      clearErrors();
    } catch (error) {
      setError(error);
      debugPrint("Error cargando proveedor ${vendor?.id}: $error");
    }
    setBusy(false);
    _loadingVendor = false;
  }

  //
  updateUiComponents() {
    //
    if (!vendor!.hasSubcategories) {
      tabBarController?.dispose();
      tabBarController = TabController(
        length: vendor!.menus.length,
        vsync: tickerProvider!,
      );

      //
      loadMenuProduts();
    } else {
      //nothing to do yet
    }
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    for (final controller in refreshContollers) {
      controller.dispose();
    }
    refreshContoller.dispose();
    super.dispose();
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

  RefreshController getRefreshController(int key) {
    int index = refreshContollerKeys.indexOf(key);
    if (index < 0) {
      refreshContollerKeys.add(vendor!.menus[key].id);
      refreshContollers.add(RefreshController());
      return refreshContollers.last;
    }
    return refreshContollers[index];
  }

  //
  loadMenuProduts() {
    generateRefreshController();

    for (final element in vendor!.menus) {
      menuProductsQueryPages[element.id] = 1;
      loadMoreProducts(element.id);
    }
  }

  generateRefreshController() {
    for (final controller in refreshContollers) {
      controller.dispose();
    }
    refreshContollers = List.generate(
      vendor!.menus.length,
      (index) => new RefreshController(),
    );
    refreshContollerKeys = List.generate(
      vendor!.menus.length,
      (index) => vendor!.menus[index].id,
    );
    notifyListeners();
  }

  //
  loadMoreProducts(int id, {bool initialLoad = true}) async {
    int queryPage = menuProductsQueryPages[id] ?? 1;
    if (initialLoad) {
      queryPage = 1;
      menuProductsQueryPages[id] = queryPage;
      getRefreshController(id).refreshCompleted();
      setBusyForObject(id, true);
    } else {
      menuProductsQueryPages[id] = ++queryPage;
    }

    try {
      final queryParams = <String, dynamic>{"vendor_id": vendor!.id};
      // El menú 0 representa "Todos". Algunos servidores interpretan
      // menu_id=0 como un menú inexistente y devuelven una lista vacía.
      if (id > 0) {
        queryParams["menu_id"] = id;
      }
      final mProducts = await _productRequest.getProdcuts(
        page: queryPage,
        queryParams: queryParams,
        forceRefresh: initialLoad,
      );

      //
      if (initialLoad) {
        menuProducts[id] = mProducts;
      } else {
        menuProducts.putIfAbsent(id, () => <Product>[]).addAll(mProducts);
      }

      if (mProducts.isEmpty) {
        getRefreshController(id).loadNoData();
      }
    } catch (error) {
      debugPrint(
        "Error cargando productos del proveedor ${vendor?.id}, menú $id: $error",
      );
    }

    //
    if (initialLoad) {
      setBusyForObject(id, false);
    } else {
      if (getRefreshController(id).isRefresh ||
          getRefreshController(id).isLoading) {
        getRefreshController(id).loadComplete();
      }
    }

    notifyListeners();
  }

  openVendorSearch() {
    viewContext.push((context) => VendorSearchPage(vendor!));
  }
}

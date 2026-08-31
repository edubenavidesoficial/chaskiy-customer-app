import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/vendor_type.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/views/pages/vendor/featured_vendors.page.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
    deliveryaddress = LocationService.deliveryaddress;
  }

  Widget? selectedPage;
  List<VendorType> vendorTypes = [];
  VendorTypeRequest vendorTypeRequest = VendorTypeRequest();
  bool showGrid = true;
  bool showSilentLoader = false;
  StreamSubscription? authStateSub;
  Timer? _silentLoaderTimer;
  bool _refreshing = false;

  //
  //
  initialise({bool initial = true}) async {
    //
    preloadDeliveryLocation();
    //
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    await getVendorTypes(showLoading: initial && vendorTypes.isEmpty);
    if (!initial) AppService().refreshHomeContent.add(true);
    listenToAuth();
    //
    handleLocationStream();
  }

  StreamSubscription? currentLocSub;
  handleLocationStream() async {
    await currentLocSub?.cancel();
    currentLocSub = LocationService.currenctDeliveryAddressSubject.listen((
      event,
    ) async {
      // La dirección sí puede cambiar la oferta disponible, pero no debe
      // desmontar Inicio ni volver a mostrar el esqueleto. Conservamos el
      // contenido actual y actualizamos los datos silenciosamente.
      await getVendorTypes(showLoading: false);
      AppService().refreshHomeContent.add(true);
    });
  }

  listenToAuth() {
    authStateSub?.cancel();
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    authStateSub?.cancel();
    currentLocSub?.cancel();
    _silentLoaderTimer?.cancel();
    super.dispose();
  }

  getVendorTypes({bool showLoading = true}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (showLoading && vendorTypes.isEmpty) {
      setBusy(true);
    } else {
      _silentLoaderTimer?.cancel();
      _silentLoaderTimer = Timer(const Duration(milliseconds: 500), () {
        if (_refreshing) {
          showSilentLoader = true;
          notifyListeners();
        }
      });
    }
    try {
      vendorTypes = await vendorTypeRequest.index();
      clearErrors();
      notifyListeners();
    } catch (error) {
      setError(error);
    }
    _refreshing = false;
    _silentLoaderTimer?.cancel();
    if (showSilentLoader) {
      showSilentLoader = false;
      notifyListeners();
    }
    if (showLoading && isBusy) setBusy(false);
  }

  openFeaturedVendors() async {
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (context) => FeaturedVendorsPage()));
  }
}

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/views/pages/taxi/widgets/new_order_step_1.dart';
import 'package:chaskiy/views/pages/taxi/widgets/new_order_step_2.dart';
import 'package:chaskiy/views/pages/taxi/widgets/taxi_rate_driver.view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/taxi_trip_ready.view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/trip_driver_search.dart';
import 'package:chaskiy/views/pages/taxi/widgets/unsupported_taxi_location.view.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> with WidgetsBindingObserver {
  //
  late TaxiViewModel taxiViewModel;

  @override
  void initState() {
    super.initState();
    taxiViewModel = TaxiViewModel(context, widget.vendorType);
  }

  //
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState. resumed) {
    // }
    taxiViewModel.setGoogleMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TaxiViewModel>.reactive(
      viewModelBuilder: () => taxiViewModel,
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: false,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          title: "${widget.vendorType.name}",
          appBarColor: Theme.of(context).colorScheme.surface,
          appBarItemColor: AppColor.primaryColor,
          body: Stack(
            children: [
              //google map
              GoogleMap(
                initialCameraPosition: vm.mapCameraPosition,
                onMapCreated: vm.onMapCreated,
                padding: vm.googleMapPadding,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                // Usamos un único control con el estilo de la aplicación.
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                markers: vm.gMapMarkers,
                polylines: vm.gMapPolylines,
                style: vm.mapStyle,
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!AppStrings.isSingleVendorMode)
                        _MapActionButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.maybePop(context),
                        )
                      else
                        const SizedBox.shrink(),
                      _MapActionButton(
                        icon: Icons.my_location_rounded,
                        onPressed: vm.zoomToCurrentLocation,
                      ),
                    ],
                  ),
                ),
              ),

              //show when location is not supported
              UnSupportedTaxiLocationView(vm),

              //new taxi order form - Step 1
              NewTaxiOrderLocationEntryView(vm),

              //new taxi order form - step 2
              NewTaxiOrderSummaryView(vm),
              //
              Visibility(
                visible: vm.currentStep(3),
                child: TripDriverSearch(vm),
              ),
              //
              Visibility(
                visible: vm.currentStep(4),
                child: TaxiTripReadyView(vm),
              ),
              //show rating after trip,
              //this will make view recrated and show rating view, instead of visibility widget
              if (vm.currentStep(6)) TaxiRateDriverView(vm),
            ],
          ),
        );
      },
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shadowColor: const Color(0x330F2A4D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: AppColor.primaryColor),
        ),
      ),
    );
  }
}

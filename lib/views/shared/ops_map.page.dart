import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:stacked/stacked.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/address.dart';
import 'package:chaskiy/view_models/ops_map.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';

class OPSMapPage extends StatelessWidget {
  const OPSMapPage({
    this.useCurrentLocation,
    this.region,
    this.initialPosition,
    this.initialZoom = 10,
    super.key,
  });

  final bool? useCurrentLocation;
  final String? region;
  final LatLng? initialPosition;
  final double initialZoom;

  @override
  Widget build(BuildContext context) {
    final initialTarget = initialPosition ?? const LatLng(0, 0);
    return BasePage(
      body: ViewModelBuilder<OPSMapViewModel>.reactive(
        viewModelBuilder: () => OPSMapViewModel(context),
        onViewModelReady:
            (vm) => vm.mapCameraMove(
              CameraPosition(target: initialTarget, zoom: initialZoom),
            ),
        builder:
            (_, vm, __) => Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: useCurrentLocation ?? true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: initialZoom,
                  ),
                  padding: vm.googleMapPadding,
                  onMapCreated: vm.onMapCreated,
                  onCameraMove: vm.mapCameraMove,
                  markers: Set<Marker>.of(vm.gMarkers.values),
                ),
                _TopMapControls(vm: vm),
                Positioned(
                  right: 20,
                  bottom: vm.selectedAddress == null ? 36 : 224,
                  child: _FloatingMapButton(
                    icon: HugeIcons.strokeRoundedLocation01,
                    onTap: () {
                      if (initialPosition != null) {
                        vm.gMapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(initialPosition!, 16),
                        );
                      }
                    },
                  ),
                ),
                if (vm.busy(vm.selectedAddress))
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 42,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 20),
                          ],
                        ),
                        child: const BusyIndicator(),
                      ),
                    ),
                  ),
                if (vm.selectedAddress != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: MeasureSize(
                      onChange: vm.updateMapPadding,
                      child: _SelectedAddressCard(vm: vm),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

class _TopMapControls extends StatelessWidget {
  const _TopMapControls({required this.vm});

  final OPSMapViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FloatingMapButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TypeAheadField<Address>(
                retainOnLoading: false,
                hideWithKeyboard: false,
                controller: vm.searchTEC,
                debounceDuration: const Duration(milliseconds: 600),
                suggestionsCallback: vm.fetchPlaces,
                itemBuilder:
                    (_, address) => ListTile(
                      leading: const Icon(HugeIcons.strokeRoundedLocation01),
                      title: Text(
                        address.featureName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        address.addressLine ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                onSelected: vm.addressSelected,
                builder:
                    (_, controller, focusNode) => Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26002A66),
                            blurRadius: 22,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: '¿A dónde vamos?',
                          prefixIcon: Icon(
                            HugeIcons.strokeRoundedSearch01,
                            color: AppColor.primaryColor,
                          ),
                          suffixIcon: const Icon(
                            HugeIcons.strokeRoundedMapPinpoint01,
                            color: Color(0xFFFF7A00),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
      elevation: 6,
      shadowColor: const Color(0x33002A66),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: AppColor.primaryColor, size: 27),
        ),
      ),
    );
  }
}

class _SelectedAddressCard extends StatelessWidget {
  const _SelectedAddressCard({required this.vm});
  final OPSMapViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33002A66),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedLocation01,
                  color: Color(0xFFFF7A00),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.selectedAddress?.featureName ?? 'Ubicación elegida',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vm.selectedAddress?.addressLine ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: vm.submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                'Confirmar ubicación'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/views/pages/order/widgets/taxi_order_trip_verification.view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/driver_info.view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/safety.view.dart';
import 'package:chaskiy/widgets/buttons/call.button.dart';
import 'package:chaskiy/widgets/buttons/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TaxiTripReadyView extends StatelessWidget {
  const TaxiTripReadyView(this.vm, {super.key});

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trip = vm.onGoingOrderTrip!;

    return SlidingUpPanel(
      backdropColor: Colors.transparent,
      minHeight: 310,
      maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      panelBuilder: (scrollController) {
        return MeasureSize(
          onChange: (_) => vm.updateGoogleMapPadding(height: 330),
          child: Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TaxiDriverInfoView(trip.driver!, order: trip),
                const SizedBox(height: 10),
                _LiveTrackingStatus(vm: vm),
                const SizedBox(height: 14),
                _ContactActions(vm: vm),
                const SizedBox(height: 22),
                Divider(height: 1, color: scheme.outlineVariant),
                const SizedBox(height: 20),
                _TripRoute(
                  pickup: '${trip.taxiOrder?.pickupAddress}',
                  dropoff: '${trip.taxiOrder?.dropoffAddress}',
                ),
                if (const {
                  'pending',
                  'preparing',
                  'ready',
                  'enroute',
                }.contains(trip.status.toLowerCase())) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: vm.busy(trip) ? null : vm.changeTripDestination,
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: Text('Cambiar destino'.tr()),
                  ),
                ],
                if (trip.status.toLowerCase() == 'enroute') ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Al llegar, comparte tu código con el conductor. Él finalizará el viaje y podrás calificarlo enseguida.'
                                .tr(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Divider(height: 1, color: scheme.outlineVariant),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: TaxiOrderTripVerificationView(trip)),
                    Container(
                      width: 1,
                      height: 92,
                      color: scheme.outlineVariant,
                    ),
                    const Expanded(child: SafetyView()),
                  ],
                ),
                if (trip.canCancelTaxi) ...[
                  const SizedBox(height: 18),
                  Divider(height: 1, color: scheme.outlineVariant),
                  const SizedBox(height: 8),
                  CustomTextButton(
                    title: 'Cancelar viaje'.tr(),
                    titleColor: AppColor.getStausColor('failed'),
                    loading: vm.busy(trip),
                    onPressed: vm.cancelTrip,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveTrackingStatus extends StatelessWidget {
  const _LiveTrackingStatus({required this.vm});

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final age = vm.driverLocationAgeSeconds;
    final stale = vm.driverLocationIsStale || age == null || age > 45;
    final color = stale ? const Color(0xFFB46A00) : const Color(0xFF16805C);
    final distance = vm.driverDistanceKm;
    final eta = vm.driverArrivalMinutes;
    final details = <String>[
      if (eta != null) 'Aprox. $eta min',
      if (distance != null)
        distance < 1
            ? '${(distance * 1000).round()} m'
            : '${distance.toStringAsFixed(1)} km',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            stale ? Icons.sync_rounded : Icons.sensors_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stale
                  ? 'Actualizando ubicación del conductor…'
                  : 'En vivo · hace ${age}s',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (details.isNotEmpty)
            Text(
              details.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({required this.vm});

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (AppUISettings.canDriverChat)
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat'.tr(),
            onPressed: vm.openTripChat,
          ),
        if (AppUISettings.canDriverChat && AppUISettings.canCallDriver)
          const SizedBox(width: 14),
        if (AppUISettings.canCallDriver)
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CallButton(
                  null,
                  phone: vm.onGoingOrderTrip?.driver?.phone,
                  size: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text('Llamar'.tr(), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TripRoute extends StatelessWidget {
  const _TripRoute({required this.pickup, required this.dropoff});

  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            children: [
              Icon(Icons.radio_button_checked, color: scheme.primary, size: 18),
              Container(width: 2, height: 45, color: scheme.outlineVariant),
              Icon(Icons.location_on_rounded, color: scheme.error, size: 20),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoutePoint(label: 'Pickup Location'.tr(), address: pickup),
              const SizedBox(height: 18),
              _RoutePoint(label: 'Dropoff Location'.tr(), address: dropoff),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.label, required this.address});

  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

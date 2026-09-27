import 'package:chaskiy/models/order.dart';

typedef FetchCurrentTaxiTrip = Future<Order?> Function();
typedef FetchTaxiTripById = Future<Order> Function(int id);
typedef RestoreTaxiTrip = Future<Order?> Function();
typedef SaveTaxiTrip = Future<void> Function(Order? order);
typedef ClearTaxiTrip = Future<void> Function();

/// Resolves the active taxi trip using the server as source of truth while
/// retaining the last valid trip through transient empty/offline responses.
class ActiveTaxiTripCoordinator {
  ActiveTaxiTripCoordinator({
    required this.fetchCurrent,
    required this.fetchById,
    required this.restoreTrip,
    required this.saveTrip,
    required this.clearTrip,
  });

  final FetchCurrentTaxiTrip fetchCurrent;
  final FetchTaxiTripById fetchById;
  final RestoreTaxiTrip restoreTrip;
  final SaveTaxiTrip saveTrip;
  final ClearTaxiTrip clearTrip;

  Future<Order?> restore() => restoreTrip();

  Future<Order?> synchronize(Order? knownTrip) async {
    try {
      final currentTrip = await fetchCurrent();
      if (currentTrip != null) {
        await _persistAccordingToState(currentTrip);
        return currentTrip;
      }
    } catch (_) {
      // A known valid trip is safer than returning the passenger to a new
      // booking screen because the phone is temporarily offline.
      if (_isActiveTaxiTrip(knownTrip)) return knownTrip;
      rethrow;
    }

    if (!_isActiveTaxiTrip(knownTrip)) {
      await clearTrip();
      return null;
    }

    try {
      final exactTrip = await fetchById(knownTrip!.id);
      await _persistAccordingToState(exactTrip);
      return exactTrip;
    } catch (_) {
      // An empty current-trip response followed by a failed detail request is
      // inconclusive. Keep the last valid state and retry on the next poll.
      return knownTrip;
    }
  }

  Future<void> remember(Order? trip) async {
    if (_isActiveTaxiTrip(trip)) await saveTrip(trip);
  }

  Future<void> _persistAccordingToState(Order trip) async {
    if (_isActiveTaxiTrip(trip)) {
      await saveTrip(trip);
    } else {
      await clearTrip();
    }
  }

  bool _isActiveTaxiTrip(Order? trip) =>
      trip != null && trip.isTaxi && trip.isOngoing && !trip.isScheduled;
}

import 'dart:async';
import 'dart:io';

import 'package:chaskiy/requests/driver.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:geolocator/geolocator.dart';

/// Owns the only continuous location stream used by the driver module.
class DriverLocationService {
  DriverLocationService._();

  static final DriverLocationService instance = DriverLocationService._();

  final DriverRequest _request = DriverRequest();
  StreamSubscription<Position>? _subscription;
  bool _syncing = false;
  DateTime? _lastSync;
  Position? _lastPosition;

  bool get isRunning => _subscription != null;
  Position? get lastPosition => _lastPosition;

  Future<void> start() async {
    if (isRunning || !SessionService.isDriver) return;
    final user = await AuthServices.getCurrentUser();
    if (!user.isOnline) return;

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const DriverLocationException(
        'Activa el servicio de ubicación para recibir pedidos.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const DriverLocationException(
        'Chaskiy necesita permiso de ubicación mientras estás disponible.',
      );
    }

    final settings = _settings();
    _subscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      _onPosition,
      onError: (_) => stop(),
      cancelOnError: false,
    );

    try {
      await _onPosition(
        await Geolocator.getCurrentPosition(
          locationSettings: settings,
        ),
      );
    } catch (_) {
      // The continuous stream remains responsible for the first valid fix.
    }
  }

  LocationSettings _settings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
        intervalDuration: const Duration(seconds: 15),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Chaskiy conductor activo',
          notificationText: 'Compartiendo ubicación para recibir pedidos',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
  }

  Future<void> _onPosition(Position position) async {
    _lastPosition = position;
    final now = DateTime.now();
    if (_syncing ||
        (_lastSync != null && now.difference(_lastSync!).inSeconds < 10)) {
      return;
    }
    if (!SessionService.isDriver ||
        AuthServices.currentUser?.isOnline != true) {
      await stop();
      return;
    }

    _syncing = true;
    try {
      await _request.syncLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
      );
      _lastSync = now;
    } catch (_) {
      // A transient network failure must not create another location stream.
      // The next eligible position retries the synchronization.
    } finally {
      _syncing = false;
    }
  }

  Future<void> stop() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    _syncing = false;
    _lastSync = null;
  }
}

class DriverLocationException implements Exception {
  const DriverLocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

import 'dart:async';
import 'dart:io';

import 'package:chaskiy/requests/driver.request.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:geolocator/geolocator.dart';

/// Owns the only continuous location stream used by the driver module.
class DriverLocationService {
  DriverLocationService._();

  static final DriverLocationService instance = DriverLocationService._();

  final DriverRequest _request = DriverRequest();
  StreamSubscription<Position>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _restartTimer;
  bool _starting = false;
  bool _syncing = false;
  bool _checkingPosition = false;
  bool _shouldRun = false;
  DateTime? _lastSync;
  Position? _lastPosition;

  bool get isRunning => _subscription != null;
  Position? get lastPosition => _lastPosition;

  Future<void> start() async {
    if (_starting || isRunning || !SessionService.isDriver) return;
    _shouldRun = true;
    _starting = true;
    try {
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
        onError: (_) => _restartAfterSensorError(),
        cancelOnError: false,
      );
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _requestFreshPosition(settings),
      );

      try {
        await _onPosition(
          await Geolocator.getCurrentPosition(locationSettings: settings),
        );
      } catch (_) {
        // The continuous stream remains responsible for the first valid fix.
      }
    } finally {
      _starting = false;
    }
  }

  /// Obtiene una lectura nueva en vez de reenviar indefinidamente la última.
  /// Así el pasajero nunca verá "En vivo" sobre un GPS que quedó congelado.
  Future<void> _requestFreshPosition(LocationSettings settings) async {
    if (_checkingPosition || !_shouldRun || !SessionService.isDriver) return;
    _checkingPosition = true;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
        timeLimit: const Duration(seconds: 10),
      );
      await _onPosition(position);
    } catch (_) {
      // Al no reenviar una coordenada vieja, el servidor la marcará como
      // desactualizada y la interfaz informará el problema con honestidad.
    } finally {
      _checkingPosition = false;
    }
  }

  /// Revalida el flujo cuando Android/iOS devuelve la app al primer plano.
  Future<void> recover() async {
    if (!SessionService.isDriver) return;
    _shouldRun = true;
    if (!isRunning) {
      await start();
      return;
    }
    await _requestFreshPosition(_settings());
  }

  LocationSettings _settings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 5),
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
        distanceFilter: 5,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  Future<void> _onPosition(Position position) async {
    _lastPosition = position;
    final now = DateTime.now();
    if (_syncing ||
        (_lastSync != null && now.difference(_lastSync!).inSeconds < 4)) {
      return;
    }
    // La disponibilidad controla nuevas solicitudes, no un viaje activo. El
    // servicio se detiene explícitamente al pasar a no disponible o cerrar
    // sesión; no debe apagarse por una copia local desactualizada de isOnline.
    if (!SessionService.isDriver || !_shouldRun) {
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
    _shouldRun = false;
    _restartTimer?.cancel();
    _restartTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    _syncing = false;
    _checkingPosition = false;
    _starting = false;
    _lastSync = null;
  }

  Future<void> _restartAfterSensorError() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    if (!_shouldRun || !SessionService.isDriver) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 3), () {
      if (_shouldRun) start();
    });
  }
}

class DriverLocationException implements Exception {
  const DriverLocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

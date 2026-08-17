import 'dart:async';

import 'package:chaskiy/models/driver_assignment.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class DriverAssignmentService {
  DriverAssignmentService._();

  static final DriverAssignmentService instance = DriverAssignmentService._();

  final StreamController<DriverAssignment> _assignments =
      StreamController<DriverAssignment>.broadcast();
  final OrderRequest _orderRequest = OrderRequest();
  Timer? _pollTimer;
  StreamSubscription<bool>? _notificationSubscription;
  bool _starting = false;
  bool _polling = false;
  String? _lastFingerprint;

  Stream<DriverAssignment> get assignments => _assignments.stream;
  bool get isRunning => _pollTimer != null;

  Future<void> start() async {
    if (_starting || isRunning || !SessionService.isDriver) return;
    _starting = true;
    try {
      final user = await AuthServices.getCurrentUser();
      if (!user.isOnline) return;

      try {
        await FirebaseMessaging.instance.subscribeToTopic('d_${user.id}');
      } catch (_) {
        // FCM solo adelanta el aviso. El sondeo API sigue funcionando aunque
        // no exista token, el permiso esté denegado o APNs aún no esté listo.
      }
      await _poll();
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
      _notificationSubscription = AppService().refreshAssignedOrders.listen((
        _,
      ) {
        _poll();
      });
    } finally {
      _starting = false;
    }
  }

  Future<void> _poll() async {
    if (_polling || !SessionService.isDriver) return;
    _polling = true;
    try {
      final assignment = await _orderRequest.getPendingDriverAssignment();
      if (assignment != null) _emitAssignment(assignment);
    } catch (_) {
      // A transient API failure must not take the driver offline. The next
      // interval and FCM signal retry automatically.
    } finally {
      _polling = false;
    }
  }

  void _emitAssignment(DriverAssignment assignment) {
    if (!SessionService.isDriver ||
        AuthServices.currentUser?.isOnline != true) {
      return;
    }
    if (assignment.orderId <= 0 || assignment.isExpired) return;
    final fingerprint = '${assignment.orderId}:${assignment.expiresAt}';
    if (_lastFingerprint == fingerprint) return;
    _lastFingerprint = fingerprint;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
    _assignments.add(assignment);
  }

  Future<void> clear(DriverAssignment assignment) async {
    _lastFingerprint = null;
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _starting = false;
    _polling = false;
    _lastFingerprint = null;
  }
}

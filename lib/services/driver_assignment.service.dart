import 'dart:async';

import 'package:chaskiy/models/driver_assignment.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DriverAssignmentService {
  DriverAssignmentService._();

  static final DriverAssignmentService instance = DriverAssignmentService._();

  final StreamController<DriverAssignment> _assignments =
      StreamController<DriverAssignment>.broadcast();
  final OrderRequest _orderRequest = OrderRequest();
  Timer? _pollTimer;
  StreamSubscription<bool>? _notificationSubscription;
  bool _polling = false;
  String? _lastFingerprint;

  Stream<DriverAssignment> get assignments => _assignments.stream;
  bool get isRunning => _pollTimer != null;

  Future<void> start() async {
    if (isRunning || !SessionService.isDriver) return;
    final user = await AuthServices.getCurrentUser();
    if (!user.isOnline) return;

    //el tema de FCM solo adelanta el aviso; quien realmente trae las
    //asignaciones es el sondeo de abajo. Si no hay token de notificaciones
    //(permiso denegado, o APNs que todavía no registra en iOS) el conductor
    //igual tiene que poder ponerse en línea.
    try {
      await FirebaseMessaging.instance.subscribeToTopic('d_${user.id}');
    } catch (error) {
      print("Unable to subscribe to:: d_${user.id}");
    }
    await _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    _notificationSubscription = AppService().refreshAssignedOrders.listen((_) {
      _poll();
    });
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
    _polling = false;
    _lastFingerprint = null;
  }
}

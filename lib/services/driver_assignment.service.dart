import 'dart:async';

import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/driver_assignment.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/websocket.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';

class DriverAssignmentService {
  DriverAssignmentService._();

  static final DriverAssignmentService instance = DriverAssignmentService._();

  final StreamController<DriverAssignment> _assignments =
      StreamController<DriverAssignment>.broadcast();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _firestoreSubscription;
  PrivateChannel? _websocketChannel;
  String? _lastFingerprint;

  Stream<DriverAssignment> get assignments => _assignments.stream;
  bool get isRunning =>
      _firestoreSubscription != null || _websocketChannel != null;

  Future<void> start() async {
    if (isRunning || !SessionService.isDriver) return;
    final user = await AuthServices.getCurrentUser();
    if (!user.isOnline) return;

    if (AppStrings.useWebsocketAssignment) {
      await _startWebsocket(user.id);
    } else {
      _startFirestore(user.id);
    }
  }

  void _startFirestore(int driverId) {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('driver_new_order')
        .doc('$driverId')
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          if (!snapshot.exists || data == null) return;
          _emit(data, documentPath: snapshot.reference.path);
        });
  }

  Future<void> _startWebsocket(int driverId) async {
    final service = WebsocketService();
    await service.init();
    final echo = service.echoClient;
    if (echo == null) return;
    final channel = echo.private('driver.new-order.$driverId');
    _websocketChannel = channel;
    channel.subscribe();
    channel.listen('.WebsocketDriverNewOrderEvent', (event) {
      if (event is Map) _emit(Map<String, dynamic>.from(event));
    });
    channel.listen('.DriverOrderAssignmentEvent', (event) {
      if (event is Map) _emit(Map<String, dynamic>.from(event));
    });
  }

  void _emit(Map<String, dynamic> data, {String? documentPath}) {
    if (!SessionService.isDriver ||
        AuthServices.currentUser?.isOnline != true) {
      return;
    }
    final assignment = DriverAssignment.fromJson(
      data,
      documentPath: documentPath,
    );
    if (assignment.orderId <= 0 || assignment.isExpired) return;
    final fingerprint = '${assignment.orderId}:${assignment.expiresAt}';
    if (_lastFingerprint == fingerprint) return;
    _lastFingerprint = fingerprint;
    _assignments.add(assignment);
  }

  Future<void> clear(DriverAssignment assignment) async {
    final path = assignment.documentPath;
    if (path != null && path.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.doc(path).delete();
      } catch (_) {}
    }
    _lastFingerprint = null;
  }

  Future<void> stop() async {
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    try {
      _websocketChannel?.unsubscribe();
    } catch (_) {}
    _websocketChannel = null;
    _lastFingerprint = null;
  }
}

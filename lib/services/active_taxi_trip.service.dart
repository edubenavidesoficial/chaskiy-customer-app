import 'dart:convert';

import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';

class ActiveTaxiTripService {
  static const _version = 'v1';
  static const _maxAge = Duration(hours: 48);

  static Future<String> _key() async {
    final user = await AuthServices.getCurrentUser();
    return 'active_taxi_trip_${_version}_${user.id}';
  }

  static Future<Order?> restore() async {
    try {
      final prefs = await LocalStorageService.getPrefs();
      final raw = prefs.getString(await _key());
      if (raw == null || raw.isEmpty) return null;
      final payload = jsonDecode(raw);
      if (payload is! Map) return null;
      final savedAt = DateTime.tryParse('${payload['saved_at']}');
      if (savedAt == null || DateTime.now().difference(savedAt) > _maxAge) {
        await clear();
        return null;
      }
      final source = payload['order'];
      if (source is! Map) return null;
      final order = Order.fromJson(Map<String, dynamic>.from(source));
      if (!order.isTaxi || !order.isOngoing || order.isScheduled) {
        await clear();
        return null;
      }
      return order;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Order? order) async {
    if (order == null ||
        !order.isTaxi ||
        !order.isOngoing ||
        order.isScheduled) {
      await clear();
      return;
    }
    try {
      final prefs = await LocalStorageService.getPrefs();
      await prefs.setString(
        await _key(),
        jsonEncode({
          'saved_at': DateTime.now().toIso8601String(),
          'order': order.toJson(),
        }),
      );
    } catch (_) {
      // La persistencia es un respaldo; nunca bloquea el viaje en vivo.
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await LocalStorageService.getPrefs();
      await prefs.remove(await _key());
    } catch (_) {}
  }
}

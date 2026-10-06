import 'dart:convert';

class DriverAssignment {
  const DriverAssignment({
    required this.orderId,
    required this.pickup,
    required this.dropoff,
    required this.amount,
    required this.total,
    required this.isTaxi,
    this.stops = const [],
    this.expiresAt,
    this.documentPath,
    this.paymentMethod,
  });

  final int orderId;
  final String pickup;
  final String dropoff;
  final String amount;
  final String total;
  final bool isTaxi;
  final List<String> stops;
  final DateTime? expiresAt;
  final String? documentPath;
  final String? paymentMethod;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory DriverAssignment.fromJson(
    Map<String, dynamic> json, {
    String? documentPath,
  }) {
    final pickup = _map(json['pickup']);
    final dropoff = _map(json['dropoff']);
    final expiryValue = json['expiresAt'] ?? json['expires_at'];
    return DriverAssignment(
      orderId: int.tryParse('${json['id'] ?? json['order_id']}') ?? 0,
      pickup: '${pickup['address'] ?? json['pickup_address'] ?? ''}',
      dropoff: '${dropoff['address'] ?? json['dropoff_address'] ?? ''}',
      amount: '${json['amount'] ?? '0.00'}',
      total: '${json['total'] ?? json['amount'] ?? '0.00'}',
      isTaxi: json['vehicle_type_id'] != null,
      paymentMethod: _paymentMethod(json['payment_method']),
      stops:
          json['stops'] is List
              ? (json['stops'] as List)
                  .whereType<Map>()
                  .map((stop) => '${stop['address'] ?? ''}')
                  .toList()
              : const [],
      expiresAt: _date(expiryValue),
      documentPath: documentPath,
    );
  }

  static String? _paymentMethod(dynamic value) {
    if (value is Map) {
      final name = '${value['name'] ?? ''}'.trim();
      final slug = '${value['slug'] ?? ''}'.toLowerCase();
      if (slug.contains('transfer') || slug.contains('deposit') || slug.contains('bank')) {
        return name.isEmpty ? 'Transferencia bancaria' : name;
      }
      return name.isEmpty ? null : name;
    }
    return null;
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return const {};
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    final asInt = int.tryParse('$value');
    if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
    return DateTime.tryParse('$value');
  }
}

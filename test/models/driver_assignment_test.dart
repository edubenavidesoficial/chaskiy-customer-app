import 'package:chaskiy/models/driver_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Firestore assignment with encoded locations', () {
    final assignment = DriverAssignment.fromJson({
      'id': '42',
      'pickup': '{"address":"Local A"}',
      'dropoff': '{"address":"Casa B"}',
      'amount': '2.50',
      'total': '12.00',
    });

    expect(assignment.orderId, 42);
    expect(assignment.pickup, 'Local A');
    expect(assignment.dropoff, 'Casa B');
    expect(assignment.isTaxi, isFalse);
  });

    test('recognizes taxi assignment payloads', () {
    final assignment = DriverAssignment.fromJson({
      'order_id': 9,
      'vehicle_type_id': 3,
      'pickup': {'address': 'Terminal'},
      'dropoff': {'address': 'Centro'},
    });

    expect(assignment.orderId, 9);
    expect(assignment.isTaxi, isTrue);
  });
}

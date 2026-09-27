import 'package:chaskiy/models/driver_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy assignment remains compatible without stops', () {
    final assignment = DriverAssignment.fromJson({'id': '12', 'amount': '4'});
    expect(assignment.orderId, 12);
    expect(assignment.stops, isEmpty);
  });
  test('offer preserves intermediate stops in server route order', () {
    final assignment = DriverAssignment.fromJson({
      'id': '12',
      'vehicle_type_id': '2',
      'stops': [
        {'sequence': 1, 'address': 'Primera parada'},
        {'sequence': 2, 'address': 'Segunda parada'},
      ],
    });
    expect(assignment.isTaxi, isTrue);
    expect(assignment.stops, ['Primera parada', 'Segunda parada']);
  });
}

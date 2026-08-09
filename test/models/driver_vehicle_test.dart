import 'package:chaskiy/models/driver_vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a complete driver vehicle response', () {
    final vehicle = DriverVehicle.fromJson({
      'id': 7,
      'reg_no': 'ABC-123',
      'color': 'Negro',
      'is_active': 1,
      'verified': true,
      'car_model': {
        'name': 'FZ',
        'car_make': {'name': 'Yamaha'},
      },
      'vehicle_type': {'name': 'Motocicleta'},
    });

    expect(vehicle.id, 7);
    expect(vehicle.make, 'Yamaha');
    expect(vehicle.model, 'FZ');
    expect(vehicle.type, 'Motocicleta');
    expect(vehicle.isActive, isTrue);
    expect(vehicle.isVerified, isTrue);
  });

  test('tolerates missing nested vehicle data', () {
    final vehicle = DriverVehicle.fromJson({'id': '2'});

    expect(vehicle.id, 2);
    expect(vehicle.make, isEmpty);
    expect(vehicle.model, isEmpty);
    expect(vehicle.isActive, isFalse);
  });
}

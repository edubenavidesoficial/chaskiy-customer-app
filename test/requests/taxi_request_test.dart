import 'package:chaskiy/requests/taxi.request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final option = <String, dynamic>{
    'id': '7',
    'name': 'Taxi',
    'is_active': true,
    'total': '3.50',
    'encrypted': 'server-quote',
  };

  test('accepts resource envelope and optional display metadata', () {
    final vehicles = TaxiRequest.parseVehicleTypes({
      'data': [option],
    });
    expect(vehicles.single.id, 7);
    expect(vehicles.single.total, 3.5);
    expect(vehicles.single.isActive, 1);
    expect(vehicles.single.encrypted, 'server-quote');
  });

  test('one malformed vehicle does not hide valid quotes', () {
    final vehicles = TaxiRequest.parseVehicleTypes([{}, option]);
    expect(vehicles.single.id, 7);
  });

  test('empty list means no availability, malformed payload means error', () {
    expect(TaxiRequest.parseVehicleTypes([]), isEmpty);
    expect(TaxiRequest.parseVehicleTypes({'data': []}), isEmpty);
    expect(
      () => TaxiRequest.parseVehicleTypes({'message': 'error'}),
      throwsFormatException,
    );
    expect(() => TaxiRequest.parseVehicleTypes([{}]), throwsFormatException);
  });
}

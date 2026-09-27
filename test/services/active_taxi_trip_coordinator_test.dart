import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/taxi_order.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/services/active_taxi_trip_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveTaxiTripCoordinator', () {
    test('servidor vacío conserva el viaje tras verificarlo por ID', () async {
      final store = _MemoryTripStore();
      final active = _taxiTrip();
      var detailChecks = 0;
      final coordinator = _coordinator(
        store: store,
        fetchCurrent: () async => null,
        fetchById: (id) async {
          detailChecks++;
          return active;
        },
      );

      final result = await coordinator.synchronize(active);

      expect(result?.id, active.id);
      expect(result?.isOngoing, isTrue);
      expect(detailChecks, 1);
      expect(store.saved?.id, active.id);
      expect(store.clearCount, 0);
    });

    test('pérdida de internet mantiene la última copia válida', () async {
      final store = _MemoryTripStore();
      final active = _taxiTrip();
      final coordinator = _coordinator(
        store: store,
        fetchCurrent: () async => throw Exception('offline'),
        fetchById: (_) async => throw StateError('no debe consultarse'),
      );

      final result = await coordinator.synchronize(active);

      expect(identical(result, active), isTrue);
      expect(store.clearCount, 0);
    });

    test('cerrar y reabrir restaura el viaje persistido', () async {
      final store = _MemoryTripStore();
      final active = _taxiTrip();
      final firstSession = _coordinator(store: store);
      await firstSession.remember(active);

      final reopenedSession = _coordinator(store: store);
      final restored = await reopenedSession.restore();

      expect(restored?.id, active.id);
      expect(restored?.status, 'preparing');
    });

    test(
      'cambiar de pantalla no reemplaza el viaje por el formulario nuevo',
      () async {
        final store = _MemoryTripStore();
        final active = _taxiTrip();
        final coordinator = _coordinator(
          store: store,
          fetchCurrent: () async => null,
          fetchById: (_) async => active,
        );

        await coordinator.remember(active);
        final resumed = await coordinator.synchronize(
          await coordinator.restore(),
        );

        expect(resumed?.id, active.id);
        expect(resumed?.isOngoing, isTrue);
        expect(store.clearCount, 0);
      },
    );

    test(
      'conductor asignado reemplaza y persiste el estado anterior',
      () async {
        final store = _MemoryTripStore();
        final searching = _taxiTrip(status: 'pending');
        final assigned = _taxiTrip(status: 'preparing', driverId: 91);
        final coordinator = _coordinator(
          store: store,
          fetchCurrent: () async => assigned,
        );

        final result = await coordinator.synchronize(searching);

        expect(result?.driverId, 91);
        expect(result?.status, 'preparing');
        expect(store.saved?.driverId, 91);
      },
    );

    test('viaje finalizado limpia la copia activa', () async {
      final store = _MemoryTripStore();
      final active = _taxiTrip();
      final completed = _taxiTrip(status: 'delivered', driverId: 91);
      final coordinator = _coordinator(
        store: store,
        fetchCurrent: () async => null,
        fetchById: (_) async => completed,
      );

      final result = await coordinator.synchronize(active);

      expect(result?.status, 'delivered');
      expect(result?.isOngoing, isFalse);
      expect(store.saved, isNull);
      expect(store.clearCount, 1);
    });
  });
}

ActiveTaxiTripCoordinator _coordinator({
  required _MemoryTripStore store,
  Future<Order?> Function()? fetchCurrent,
  Future<Order> Function(int)? fetchById,
}) {
  return ActiveTaxiTripCoordinator(
    fetchCurrent: fetchCurrent ?? () async => store.saved,
    fetchById: fetchById ?? (_) async => store.saved!,
    restoreTrip: () async => store.saved,
    saveTrip: store.save,
    clearTrip: store.clear,
  );
}

class _MemoryTripStore {
  Order? saved;
  int clearCount = 0;

  Future<void> save(Order? order) async {
    saved = order;
  }

  Future<void> clear() async {
    saved = null;
    clearCount++;
  }
}

Order _taxiTrip({String status = 'preparing', int? driverId}) {
  final now = DateTime(2026, 8, 31, 11, 22);
  final vehicleType = VehicleType(
    id: 3,
    name: 'Chaskiy Standard',
    slug: 'chaskiy-standard',
    baseFare: 1.45,
    distanceFare: 0.25,
    timeFare: 0.10,
    minFare: 1.50,
    isActive: 1,
    createdAt: now,
    updatedAt: now,
    formattedDate: '31 ago 2026',
    photo: '',
    total: 2.11,
    tax: 0,
    encrypted: 'vehicle-3',
    currency: null,
  );
  return Order(
    id: 8345017087,
    code: '6648025340',
    status: status,
    type: 'taxi',
    userId: 14,
    driverId: driverId,
    createdAt: now,
    updatedAt: now,
    formattedDate: '31 ago 2026, 11:22',
    user: User(
      id: 14,
      name: 'Cliente prueba',
      email: 'cliente@example.test',
      phone: '0990000000',
      countryCode: '+593',
      photo: '',
      role: 'client',
      walletAddress: '',
    ),
    taxiOrder: TaxiOrder(
      id: 801,
      orderId: 8345017087,
      vehicleTypeId: 3,
      pickupLatitude: '-0.0020',
      pickupLongitude: '-78.4460',
      pickupAddress: 'Catequilla, Quito, Ecuador',
      dropoffLatitude: '-0.0060',
      dropoffLongitude: '-78.4550',
      dropoffAddress: 'Mitad del Mundo, Quito, Ecuador',
      createdAt: now,
      updatedAt: now,
      vehicleType: vehicleType,
    ),
  );
}

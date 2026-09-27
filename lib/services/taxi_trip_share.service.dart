import 'package:chaskiy/models/order.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chaskiy/requests/taxi.request.dart';
import 'package:chaskiy/models/api_response.dart';

class TaxiTripShareService {
  static Future<void> share(Order order) async {
    final taxi = order.taxiOrder;
    if (taxi == null) return;

    final response = ApiResponse.fromResponse(
      await TaxiRequest().post('/taxi/order/${order.id}/share', {}),
    );
    if (!response.allGood ||
        response.body is! Map ||
        response.body['url'] is! String) {
      throw response.message ?? 'No se pudo crear el enlace de seguimiento';
    }
    final trackingUrl = response.body['url'] as String;
    final driver = order.driver;
    final vehicle = driver?.vehicle;
    final route = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '${taxi.pickupLatitude},${taxi.pickupLongitude}',
      'destination': '${taxi.dropoffLatitude},${taxi.dropoffLongitude}',
      'travelmode': 'driving',
    });
    final details = <String>[
      'Estoy realizando un viaje con Taxi Seguro Chaskiy.',
      'Viaje: #${order.code}',
      'Estado: ${_status(order.status)}',
      if (driver != null) 'Conductor: ${driver.name}',
      if (vehicle != null) 'Vehículo: ${vehicle.vehicleInfo}',
      if (vehicle != null) 'Placa: ${vehicle.reg_no}',
      'Recogida: ${taxi.pickupAddress}',
      'Destino: ${taxi.dropoffAddress}',
      'Seguimiento en vivo (válido por 12 horas): $trackingUrl',
      'Ruta de referencia: $route',
      '',
      'Mensaje compartido por seguridad. No incluye el código de verificación.',
    ];

    await SharePlus.instance.share(
      ShareParams(
        subject: 'Mi viaje seguro Chaskiy #${order.code}',
        text: details.join('\n'),
      ),
    );
  }

  static String _status(String status) {
    const labels = {
      'pending': 'Buscando conductor',
      'preparing': 'Conductor asignado',
      'ready': 'Conductor en camino',
      'enroute': 'En viaje',
      'delivered': 'Finalizado',
      'completed': 'Finalizado',
    };
    return labels[status.toLowerCase()] ?? status;
  }
}

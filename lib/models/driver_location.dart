/// Última ubicación conocida del conductor de un pedido.
///
/// Llega de `POST /orders/{order}/driver/location/sync`, que responde con la
/// fila de `driver_locations`: `lat`, `lng` y `rotation`. En la base son
/// cadenas y el modelo de Laravel las castea a double, así que aquí se aceptan
/// las dos formas.
class DriverLocation {
  DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.rotation,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) => DriverLocation(
    latitude: _toDouble(json["lat"]),
    longitude: _toDouble(json["lng"]),
    //sin rumbo el marcador simplemente no gira
    rotation: _toDouble(json["rotation"], fallback: 0),
  );

  final double latitude;
  final double longitude;
  final double rotation;

  /// Coordenadas dentro del rango real del planeta.
  ///
  /// Un dato ausente o no numérico llega como `NaN`, que falla toda
  /// comparación, así que esas filas se descartan solas.
  bool get isValid => latitude.abs() <= 90 && longitude.abs() <= 180;

  static double _toDouble(dynamic value, {double fallback = double.nan}) {
    if (value is num) return value.toDouble();
    return double.tryParse("$value") ?? fallback;
  }
}

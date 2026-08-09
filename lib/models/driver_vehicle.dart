class DriverVehicle {
  const DriverVehicle({
    required this.id,
    required this.registrationNumber,
    required this.color,
    required this.make,
    required this.model,
    required this.type,
    required this.photo,
    required this.isActive,
    required this.isVerified,
  });

  final int id;
  final String registrationNumber;
  final String color;
  final String make;
  final String model;
  final String type;
  final String photo;
  final bool isActive;
  final bool isVerified;

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    final carModel = _map(json['car_model']);
    final carMake = _map(carModel['car_make']);
    final vehicleType = _map(json['vehicle_type']);
    return DriverVehicle(
      id: int.tryParse('${json['id']}') ?? 0,
      registrationNumber: '${json['reg_no'] ?? ''}',
      color: '${json['color'] ?? ''}',
      make: '${carMake['name'] ?? ''}',
      model: '${carModel['name'] ?? ''}',
      type: '${vehicleType['name'] ?? ''}',
      photo: '${json['photo'] ?? vehicleType['photo'] ?? ''}',
      isActive: _bool(json['is_active']),
      isVerified: _bool(json['verified']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reg_no': registrationNumber,
    'color': color,
    'photo': photo,
    'is_active': isActive ? 1 : 0,
    'verified': isVerified,
    'car_model': {
      'name': model,
      'car_make': {'name': make},
    },
    'vehicle_type': {'name': type},
  };

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    return value == 1 || value?.toString() == '1';
  }
}

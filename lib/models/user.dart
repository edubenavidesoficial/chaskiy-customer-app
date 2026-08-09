class User {
  int id;

  String name;
  String? code;
  String email;
  String phone;
  String? rawPhone;
  String? countryCode;
  String photo;
  String role;
  List<String> roleNames;
  String? driverStatus;
  String walletAddress;
  int? vendorId;
  double rating;
  bool isOnline;
  bool isTaxiDriver;
  bool documentRequested;
  bool pendingDocumentApproval;

  User({
    required this.id,
    this.code,
    required this.name,
    required this.email,
    required this.phone,
    this.rawPhone,
    required this.countryCode,
    required this.photo,
    required this.role,
    this.roleNames = const [],
    this.driverStatus,
    required this.walletAddress,
    this.vendorId,
    this.rating = 5,
    this.isOnline = false,
    this.isTaxiDriver = false,
    this.documentRequested = false,
    this.pendingDocumentApproval = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final role = json['role_name']?.toString() ?? "client";
    final rawRoles = json['role_names'] ?? json['roles'];
    final roles =
        rawRoles is List
            ? rawRoles
                .map((value) => value is Map ? value['name'] : value)
                .whereType<Object>()
                .map((value) => value.toString())
                .toList()
            : <String>[];
    if (!roles.contains(role)) roles.add(role);

    return User(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? "",
      rawPhone: json['raw_phone'],
      walletAddress: json['wallet_address'] ?? "",
      countryCode: json['country_code'],
      photo: json['photo'] ?? "",
      role: role,
      roleNames: roles,
      driverStatus: json['driver_access_status'] ?? json['driver_status'],
      vendorId: json['vendor_id'],
      rating: double.tryParse('${json['rating'] ?? 5}') ?? 5,
      isOnline: _jsonBool(json['is_online']),
      isTaxiDriver: _jsonBool(json['is_taxi_driver']),
      documentRequested: _jsonBool(json['document_requested']),
      pendingDocumentApproval: _jsonBool(json['pending_document_approval']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'email': email,
      'phone': phone,
      'raw_phone': rawPhone,
      'country_code': countryCode,
      'photo': photo,
      'role_name': role,
      'role_names': roleNames,
      'driver_access_status': driverStatus,
      'wallet_address': walletAddress,
      'vendor_id': vendorId,
      'rating': rating,
      'is_online': isOnline ? 1 : 0,
      'is_taxi_driver': isTaxiDriver ? 1 : 0,
      'document_requested': documentRequested,
      'pending_document_approval': pendingDocumentApproval,
    };
  }

  bool hasRole(String value) => roleNames.any(
    (roleName) => roleName.toLowerCase() == value.toLowerCase(),
  );

  bool get hasDriverRole => hasRole('driver');
  bool get hasCustomerRole => hasRole('client') || hasRole('customer');
  bool get driverAccessApproved =>
      hasDriverRole && (driverStatus == null || driverStatus == 'approved');

  static bool _jsonBool(dynamic value) {
    if (value is bool) return value;
    return value == 1 || value?.toString() == '1';
  }
}

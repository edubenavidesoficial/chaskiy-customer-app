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
    required this.walletAddress,
    this.vendorId,
    this.rating = 5,
    this.isOnline = false,
    this.isTaxiDriver = false,
    this.documentRequested = false,
    this.pendingDocumentApproval = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
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
      role: json['role_name'] ?? "client",
      vendorId: json['vendor_id'],
      rating: double.tryParse('${json['rating'] ?? 5}') ?? 5,
      isOnline: _jsonBool(json['is_online']),
      isTaxiDriver: _jsonBool(json['is_taxi_driver']),
      documentRequested: _jsonBool(json['document_requested']),
      pendingDocumentApproval: _jsonBool(
        json['pending_document_approval'],
      ),
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
      'wallet_address': walletAddress,
      'vendor_id': vendorId,
      'rating': rating,
      'is_online': isOnline ? 1 : 0,
      'is_taxi_driver': isTaxiDriver ? 1 : 0,
      'document_requested': documentRequested,
      'pending_document_approval': pendingDocumentApproval,
    };
  }

  static bool _jsonBool(dynamic value) {
    if (value is bool) return value;
    return value == 1 || value?.toString() == '1';
  }
}

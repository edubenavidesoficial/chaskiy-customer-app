enum AppRole {
  guest,
  customer,
  driver;

  static AppRole fromBackendRole(String? role) {
    switch (role?.trim().toLowerCase()) {
      case 'driver':
        return AppRole.driver;
      case 'client':
      case 'customer':
        return AppRole.customer;
      default:
        return AppRole.guest;
    }
  }

  String get storageValue => name;
}

import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/enums/app_role.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/services/local_storage.service.dart';

/// Single source of truth for the active application role.
///
/// Driver-only background services must consult this service before starting.
class SessionService {
  SessionService._();

  static AppRole? _cachedRole;

  static AppRole get activeRole {
    final cachedRole = _cachedRole;
    if (cachedRole != null) return cachedRole;

    final storedRole = LocalStorageService.prefs?.getString(
      AppStrings.activeRole,
    );
    _cachedRole = AppRole.values.firstWhere(
      (role) => role.storageValue == storedRole,
      orElse: () => AppRole.guest,
    );
    return _cachedRole!;
  }

  static bool get isCustomer => activeRole == AppRole.customer;
  static bool get isDriver => activeRole == AppRole.driver;

  static bool canUseRole(User user, AppRole role) {
    return switch (role) {
      AppRole.customer => user.hasCustomerRole,
      AppRole.driver => user.driverAccessApproved,
      AppRole.guest => false,
    };
  }

  static Future<void> setUser(User user, {AppRole? preferredRole}) async {
    final currentRole = activeRole;
    final backendRole = AppRole.fromBackendRole(user.role);
    final role =
        preferredRole != null && canUseRole(user, preferredRole)
            ? preferredRole
            : canUseRole(user, currentRole)
            ? currentRole
            : canUseRole(user, backendRole)
            ? backendRole
            : user.hasCustomerRole
            ? AppRole.customer
            : AppRole.guest;
    await setActiveRole(role, user: user);
  }

  static Future<void> setActiveRole(AppRole role, {required User user}) async {
    if (role != AppRole.guest && !canUseRole(user, role)) {
      throw StateError('El usuario no tiene acceso al modo ${role.name}');
    }
    _cachedRole = role;
    await LocalStorageService.prefs?.setString(
      AppStrings.activeRole,
      role.storageValue,
    );
  }

  static Future<void> clear() async {
    _cachedRole = AppRole.guest;
    await LocalStorageService.prefs?.remove(AppStrings.activeRole);
  }

  static void resetCacheForTesting() {
    _cachedRole = null;
  }
}

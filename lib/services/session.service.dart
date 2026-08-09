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

  static Future<void> setUser(User user) async {
    final role = AppRole.fromBackendRole(user.role);
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

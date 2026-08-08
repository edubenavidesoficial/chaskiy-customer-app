import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/local_storage.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/utils/utils.dart';

class PhoneUtilService {
  static Country? _userCountry;
  static bool _isInitialized = false;
  static Future<void>? _initialization;
  static const String _storageKey = 'USER_COUNTRY_CODE';

  /// Valores del ajuste *Código del país* que significan "sin restricción".
  static const List<String> _unrestrictedCodes = ["INTERNATIONAL", "AUTO"];

  /// Último recurso, solo si ninguna señal (cuenta, GPS, IP, dispositivo ni
  /// panel) logra resolver un país.
  static const String _lastResortCode = "EC";

  /// Initialize the service - call this on app startup
  static Future<void> init() async {
    if (_isInitialized) return;
    if (_initialization != null) return _initialization;
    _initialization = _initialize();
    return _initialization;
  }

  static Future<void> _initialize() async {
    try {
      await getUserCountry();
      _isInitialized = true;
      print(
        'PhoneUtilService initialized with country: ${_userCountry?.countryCode}',
      );
    } catch (e) {
      print('Error initializing PhoneUtilService: $e');
      // Set fallback even if init fails
      _userCountry = defaultCountry();
      _isInitialized = true;
    } finally {
      _initialization = null;
    }
  }

  /// Resuelve dónde está realmente el usuario, de la señal más confiable a la
  /// menos: ubicación del GPS ya geocodificada, país de la IP, región
  /// configurada en el dispositivo y, si no hay red, el último país conocido.
  ///
  /// Se vuelve a resolver en cada arranque —la caché es solo respaldo— para
  /// que un país mal detectado no se quede pegado en el dispositivo.
  static Future<Country?> getUserCountry() async {
    if (_userCountry != null) {
      return _userCountry;
    }

    // No consultamos la SIM porque es una API obsoleta en iOS y añade trabajo
    // innecesario al arranque.
    _userCountry =
        _parseCountry(LocationService.currenctAddress?.countryCode) ??
        await _getCountryFromIp() ??
        await _getCountryFromLocale() ??
        _parseCountry(await _getCachedCountryCode());

    // Cache the result
    if (_userCountry != null) {
      await _cacheCountryCode(_userCountry!.countryCode);
    }

    return _userCountry;
  }

  /// Países que el panel permite en los selectores de teléfono, tomados del
  /// ajuste *Código del país* (admite varios separados por coma).
  ///
  /// Devuelve `null` cuando el panel está en INTERNATIONAL o AUTO, es decir
  /// cuando no hay restricción y se deben mostrar todos.
  static List<String>? get allowedCountryCodes {
    String raw;
    try {
      raw = AppStrings.countryCode;
    } catch (e) {
      // El ajuste todavía no llega desde el servidor.
      return null;
    }

    final codes =
        raw
            .split(",")
            .map((code) => code.trim().toUpperCase())
            .where(
              (code) => code.isNotEmpty && !_unrestrictedCodes.contains(code),
            )
            .where((code) => Country.tryParse(code) != null)
            .toList();

    return codes.isEmpty ? null : codes;
  }

  /// País que deben mostrar por defecto los selectores de teléfono.
  ///
  /// Nada está fijo en el código: se toma el país guardado en la cuenta
  /// (para no alterar un número ya validado), luego dónde está el usuario y
  /// por último lo que diga el panel. El resultado siempre queda dentro de
  /// los países que el panel permite.
  static Country defaultCountry({String? accountCountryCode}) {
    final allowed = allowedCountryCodes;

    Country? pick(String? value) {
      final country = _parseCountry(value);
      if (country == null) {
        return null;
      }
      final isAllowed =
          allowed == null ||
          allowed.contains(country.countryCode.toUpperCase());
      return isAllowed ? country : null;
    }

    return pick(accountCountryCode) ??
        pick(LocationService.currenctAddress?.countryCode) ??
        pick(_userCountry?.countryCode) ??
        pick(allowed?.first) ??
        Country.parse(_lastResortCode);
  }

  /// Convierte un código o nombre de país en [Country]; `null` si no aplica.
  static Country? _parseCountry(String? value) {
    final raw = value?.trim() ?? "";
    return raw.isEmpty ? null : Country.tryParse(raw);
  }

  /// País según la IP desde la que se conecta el dispositivo.
  static Future<Country?> _getCountryFromIp() async {
    try {
      return _parseCountry(await Utils.getCurrentCountryCode());
    } catch (e) {
      print('Error getting country from IP: $e');
      return null;
    }
  }

  /// Get country code (2-letter ISO code)
  static Future<String?> getCountryCode() async {
    final country = await getUserCountry();
    return country?.countryCode;
  }

  /// Get country calling code (phone prefix)
  static Future<String?> getCountryCallingCode() async {
    final country = await getUserCountry();
    return country?.phoneCode;
  }

  /// Get country code synchronously (after init)
  static String? get countryCode {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry?.countryCode;
  }

  /// Get country calling code synchronously (after init)
  static String? get countryCallingCode {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry?.phoneCode;
  }

  /// Get user country synchronously (after init)
  static Country? get userCountry {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry;
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get country from device locale
  static Future<Country?> _getCountryFromLocale() async {
    try {
      final locale = Platform.localeName;
      String? countryCode;

      if (locale.contains('_')) {
        countryCode = locale.split('_').last.toUpperCase();
      } else if (locale.contains('-')) {
        countryCode = locale.split('-').last.toUpperCase();
      }

      if (countryCode != null && countryCode.length == 2) {
        return Country.tryParse(countryCode);
      }
    } catch (e) {
      print('Error getting country from locale: $e');
    }

    return null;
  }

  /// Clear cached country (useful for testing or manual selection)
  static Future<void> clearCachedCountry() async {
    _userCountry = null;
    final pref = await LocalStorageService.getPrefs();
    await pref.remove(_storageKey);
  }

  /// Manually set user country
  static Future<void> setUserCountry(Country country) async {
    _userCountry = country;
    await _cacheCountryCode(country.countryCode);
  }

  /// Cache country code locally
  static Future<void> _cacheCountryCode(String countryCode) async {
    try {
      final pref = await LocalStorageService.getPrefs();
      await pref.setString(_storageKey, countryCode);
    } catch (e) {
      print('Error caching country code: $e');
    }
  }

  /// Get cached country code
  static Future<String?> _getCachedCountryCode() async {
    try {
      final pref = await LocalStorageService.getPrefs();
      return pref.getString(_storageKey);
    } catch (e) {
      print('Error getting cached country code: $e');
      return null;
    }
  }

  /// Format phone number with country code
  static String formatPhoneWithCountryCode(
    String phoneNumber,
    String countryCode,
  ) {
    final country = Country.tryParse(countryCode);
    if (country != null) {
      // Remove any existing country code or leading zeros
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'^(\+|00)'), '');
      if (cleanNumber.startsWith(country.phoneCode)) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length);
      }
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }

      return '+${country.phoneCode}$cleanNumber';
    }
    return phoneNumber;
  }

  /// Validate phone number for a specific country
  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    try {
      final country = Country.tryParse(countryCode);
      if (country == null) return false;

      // Basic validation - remove spaces, dashes, parentheses
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // Remove country code if present
      if (cleanNumber.startsWith('+${country.phoneCode}')) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length + 1);
      } else if (cleanNumber.startsWith(country.phoneCode)) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length);
      }

      // Remove leading zero if present
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }

      // Basic length validation (most phone numbers are 7-15 digits)
      return cleanNumber.length >= 7 &&
          cleanNumber.length <= 15 &&
          RegExp(r'^\d+$').hasMatch(cleanNumber);
    } catch (e) {
      print('Error validating phone number: $e');
      return false;
    }
  }

  /// Get list of all available countries
  static List<Country> getAllCountries() {
    return CountryService().getAll();
  }

  /// Search countries by name or code
  static List<Country> searchCountries(String query) {
    final allCountries = getAllCountries();
    final lowerQuery = query.toLowerCase();

    return allCountries.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.countryCode.toLowerCase().contains(lowerQuery) ||
          country.phoneCode.contains(query);
    }).toList();
  }
}

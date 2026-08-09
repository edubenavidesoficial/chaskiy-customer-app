import 'package:flutter/material.dart';

/// Colores con significado que Material 3 no cubre: éxito, aviso y estrella.
///
/// Estaban quemados en cada pantalla (`Color(0xFF087F5B)`, `Color(0xFFFFB000)`,
/// etc.), así que el mismo verde tenía tres tonos distintos y ninguno se
/// adaptaba al tema oscuro. Ahora viven en el tema y se leen con
/// `Theme.of(context).semantics`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.star,
  });

  /// Disponible, abierto, confirmado.
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Atención sin ser un error: entrega, pendiente, por confirmar.
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Amarillo de las calificaciones.
  final Color star;

  static const light = AppSemanticColors(
    success: Color(0xFF087F5B),
    successContainer: Color(0xFFDDF8ED),
    onSuccessContainer: Color(0xFF04543C),
    warning: Color(0xFF9A5B00),
    warningContainer: Color(0xFFFFF0C2),
    onWarningContainer: Color(0xFF6B3F00),
    star: Color(0xFFFFB000),
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF52D6A6),
    successContainer: Color(0xFF10352A),
    onSuccessContainer: Color(0xFFA8EFD3),
    warning: Color(0xFFFFC46B),
    warningContainer: Color(0xFF3D2A08),
    onWarningContainer: Color(0xFFFFE1AE),
    star: Color(0xFFFFC53D),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? star,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      star: star ?? this.star,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      star: Color.lerp(star, other.star, t)!,
    );
  }
}

extension AppSemanticColorsTheme on ThemeData {
  /// Atajo para no repetir `extension<AppSemanticColors>()!` en cada pantalla.
  AppSemanticColors get semantics =>
      extension<AppSemanticColors>() ??
      (brightness == Brightness.dark
          ? AppSemanticColors.dark
          : AppSemanticColors.light);
}

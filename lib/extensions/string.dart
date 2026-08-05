import 'package:currency_formatter/currency_formatter.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:supercharged/supercharged.dart';

extension NumberParsing on dynamic {
  //
  String currencyFormat([String? currencySymbol]) {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      //
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      final decimalsValue = "".padLeft(decimals.toString().toInt()!, "0");

      //
      if (this.toString().contains(AppStrings.currentCurrencySymbol)) {
        currencySymbol = AppStrings.currentCurrencySymbol;
      }
      //
      final values = this
          .toString()
          .split(" ")
          .join("")
          .split(currencySymbol ?? AppStrings.currencySymbol);

      //
      CurrencyFormat currencySettings = CurrencyFormat(
        symbol: currencySymbol ?? AppStrings.currencySymbol,
        symbolSide:
            currencylOCATION.toLowerCase() == "left"
                ? SymbolSide.left
                : SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );

      return CurrencyFormatter.format(
        values[1],
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }

  //
  String currencyValueFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final decimalsValue = "".padLeft(decimals.toString().toInt()!, "0");
      final values = this.toString().split(" ").join("");

      //
      CurrencyFormat currencySettings = CurrencyFormat(
        symbol: "",
        symbolSide: SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );
      return CurrencyFormatter.format(
        values,
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return this.toString();
    }
  }

  bool get isNotDefaultImage {
    return !this.toString().contains("default");
  }

  String maskString({int start = 3, int? end, String mask = "*"}) {
    final String value = this.toString();
    // make sure start and end are within the string length
    if (start < 0) {
      start = 0;
    }

    int endPoint = end ?? value.length;
    if (endPoint > value.length) {
      endPoint = value.length;
    }

    // get the front and end of the string
    final String frontString = start == 0 ? "" : value.substring(0, start);
    final String endString = value.substring(endPoint);
    final String maskedString = "$mask".padLeft(
      value.substring(start, endPoint).length,
      "$mask",
    );
    return "$frontString$maskedString$endString";
  }
}

extension HtmlStringParsing on String {
  /// Convierte el HTML que llega del backend (editor de texto enriquecido) en
  /// texto plano: así se muestra con la tipografía y los colores de la app y
  /// no con los estilos incrustados del editor (fondos blancos, fuentes, etc).
  String get htmlToPlainText {
    var value = this;

    // saltos de línea antes de quitar las etiquetas
    value = value.replaceAll(
      RegExp(r'<br\s*/?>|</p>|</div>|</li>|</h[1-6]>', caseSensitive: false),
      '\n',
    );
    // etiquetas y comentarios
    value = value.replaceAll(RegExp(r'<[^>]*>'), '');
    // entidades más comunes
    const entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&aacute;': 'á',
      '&eacute;': 'é',
      '&iacute;': 'í',
      '&oacute;': 'ó',
      '&uacute;': 'ú',
      '&ntilde;': 'ñ',
      '&uuml;': 'ü',
    };
    entities.forEach((entity, char) {
      value = value.replaceAll(RegExp(entity, caseSensitive: false), char);
    });

    // espacios sobrantes y líneas en blanco repetidas
    value = value.replaceAll(RegExp(r'[ \t]+'), ' ');
    value = value.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return value.split('\n').map((line) => line.trim()).join('\n').trim();
  }
}

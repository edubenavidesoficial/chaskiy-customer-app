import 'package:localize_and_translate/localize_and_translate.dart';

class ApiResponse {
  static const String unavailableMessage =
      "El servicio no está disponible temporalmente. Inténtalo nuevamente en unos minutos.";

  int get totalDataCount {
    if (body is! Map) return 0;
    final meta = (body as Map)["meta"];
    if (meta is! Map) return 0;
    return int.tryParse("${meta["total"] ?? 0}") ?? 0;
  }

  int get totalPageCount {
    if (body is! Map) return 0;
    final pagination = (body as Map)["pagination"];
    if (pagination is! Map) return 0;
    return int.tryParse("${pagination["total_pages"] ?? 0}") ?? 0;
  }

  List get data {
    if (body is List) return body as List;
    if (body is! Map) return const [];
    final responseData = (body as Map)["data"];
    return responseData is List ? responseData : const [];
  }

  /// El mensaje del servidor listo para mostrarse.
  ///
  /// La API responde en inglés, así que los mensajes que el usuario llega a
  /// ver se buscan en el diccionario del idioma activo. Si la clave no está,
  /// `.tr()` devuelve el texto original y no se pierde nada.
  String? get localizedMessage => message?.tr();
  // Just a way of saying there was no error with the request and response return
  bool get allGood => errors == null || errors?.length == 0;
  bool hasError() => errors != null && ((errors?.length ?? 0) > 0);
  bool hasData() => data.isNotEmpty;
  int? code;
  String? message;
  dynamic body;
  List? errors;

  ApiResponse({this.code, this.message, this.body, this.errors});

  factory ApiResponse.fromResponse(dynamic response) {
    final int code = response.statusCode ?? 503;
    final dynamic body = response.data;
    List errors = [];
    String message = "";
    final bool successfulStatus = code >= 200 && code < 300;
    final bool validJsonBody = body is Map || body is List;

    if (successfulStatus && validJsonBody) {
      if (body is Map && body["message"] != null) {
        message = body["message"].toString();
      }
    } else {
      if (body is Map && body["message"] != null) {
        message = body["message"].toString();
      } else {
        message = unavailableMessage;
      }
      errors.add(message);
    }

    return ApiResponse(
      code: code,
      message: message,
      body: body,
      errors: errors,
    );
  }
}

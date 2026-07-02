class ApiResponse {
  int get totalDataCount => body["meta"]["total"];
  int get totalPageCount => body["pagination"]["total_pages"];
  List get data => body["data"] ?? [];
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
    //
    int code = response.statusCode;
    dynamic body = response.data ?? null; // Would mostly be a Map
    List errors = [];
    String message = "";

    switch (code) {
      case 200:
        try {
          if (body is String) {
            final lowerBody = body.toLowerCase();
            if (lowerBody.contains("<html") ||
                lowerBody.contains("one moment")) {
              message =
                  "No se pudo conectar con el servidor. Intenta nuevamente en unos segundos.";
              errors.add(message);
            }
          } else {
            message = body is Map ? (body["message"] ?? "") : "";
          }
        } catch (error) {
          print("Message reading error ==> $error");
        }

        break;
      default:
        message = body is Map
            ? (body["message"] ??
                  "Ocurrió un error. Intenta nuevamente o contacta a soporte.")
            : "Ocurrió un error. Intenta nuevamente o contacta a soporte.";
        errors.add(message);
        break;
    }

    return ApiResponse(
      code: code,
      message: message,
      body: body,
      errors: errors,
    );
  }
}

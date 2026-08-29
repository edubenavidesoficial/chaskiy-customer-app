import 'package:chaskiy/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> response(int statusCode, dynamic data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/test'),
    statusCode: statusCode,
    data: data,
  );
}

void main() {
  group('ApiResponse', () {
    test('accepts a successful JSON map', () {
      final result = ApiResponse.fromResponse(
        response(200, {
          'message': 'OK',
          'data': [1, 2],
        }),
      );

      expect(result.allGood, isTrue);
      expect(result.message, 'OK');
      expect(result.data, [1, 2]);
    });

    test('accepts a successful top-level JSON list', () {
      final result = ApiResponse.fromResponse(response(200, [1, 2, 3]));

      expect(result.allGood, isTrue);
      expect(result.data, [1, 2, 3]);
    });

    test('rejects an HTML page returned with status 200', () {
      final result = ApiResponse.fromResponse(
        response(200, '<html><h1>509 Bandwidth Limit Exceeded</h1></html>'),
      );

      expect(result.allGood, isFalse);
      expect(result.message, ApiResponse.unavailableMessage);
      expect(result.data, isEmpty);
      expect(result.message, isNot(contains('html')));
    });

    test('rejects an HTML server error without exposing its contents', () {
      final result = ApiResponse.fromResponse(
        response(500, '<html>Internal Server Error</html>'),
      );

      expect(result.allGood, isFalse);
      expect(result.message, ApiResponse.unavailableMessage);
      expect(result.data, isEmpty);
    });

    test('preserves a JSON validation message', () {
      final result = ApiResponse.fromResponse(
        response(422, {'message': 'Datos inválidos'}),
      );

      expect(result.allGood, isFalse);
      expect(result.message, 'Datos inválidos');
    });

    test('hides Imunify360 infrastructure details from customers', () {
      final result = ApiResponse.fromResponse(
        response(403, {
          'message':
              'Access denied by Imunify360 bot-protection. IPs used for automation should be whitelisted',
        }),
      );

      expect(result.allGood, isFalse);
      expect(result.message, ApiResponse.unavailableMessage);
      expect(result.message, isNot(contains('Imunify360')));
      expect(result.message, isNot(contains('whitelisted')));
    });
  });
}

import 'package:chaskiy/enums/app_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRole.fromBackendRole', () {
    test('maps customer backend roles', () {
      expect(AppRole.fromBackendRole('client'), AppRole.customer);
      expect(AppRole.fromBackendRole('customer'), AppRole.customer);
    });

    test('maps driver role ignoring case and whitespace', () {
      expect(AppRole.fromBackendRole(' Driver '), AppRole.driver);
    });

    test('keeps unknown or missing roles unauthenticated', () {
      expect(AppRole.fromBackendRole(null), AppRole.guest);
      expect(AppRole.fromBackendRole('vendor'), AppRole.guest);
    });
  });
}

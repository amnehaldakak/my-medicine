import 'package:flutter_test/flutter_test.dart';
import 'package:my_medicine/data/repositories/auth_repository.dart';
import 'package:my_medicine/presentation/controllers/auth_controller.dart';

void main() {
  late AuthController controller;

  setUp(() {
    controller = AuthController(MockAuthRepository());
  });

  group('AuthController', () {
    test('initial status is initial', () {
      expect(controller.status, AuthStatus.initial);
      expect(controller.isAuthenticated, false);
    });

    test('login sets authenticated status and user', () async {
      final ok = await controller.login('test@example.com', 'password');
      expect(ok, true);
      expect(controller.status, AuthStatus.authenticated);
      expect(controller.isAuthenticated, true);
      expect(controller.user, isNotNull);
      expect(controller.user!.email, 'test@example.com');
    });

    test('createAccount sets authenticated status', () async {
      final ok = await controller.createAccount(
          'Jane Doe', 'jane@example.com', 'secret');
      expect(ok, true);
      expect(controller.isAuthenticated, true);
      expect(controller.user!.name, 'Jane Doe');
    });

    test('logout clears user and sets unauthenticated', () async {
      await controller.login('test@example.com', 'password');
      await controller.logout();
      expect(controller.isAuthenticated, false);
      expect(controller.user, isNull);
      expect(controller.status, AuthStatus.unauthenticated);
    });
  });
}

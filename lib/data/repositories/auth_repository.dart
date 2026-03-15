import '../models/user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> createAccount(String name, String email, String password);
  Future<void> logout();
  AppUser? get currentUser;
}

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(
      id: 'user-1',
      name: 'Alex Johnson',
      email: email,
    );
    return _currentUser;
  }

  @override
  Future<AppUser?> createAccount(
      String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(id: 'user-1', name: name, email: email);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}

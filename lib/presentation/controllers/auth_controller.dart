import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  AuthController(this._repo) {
    // Check if already logged in on app launch
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final existing = _repo.currentUser;
    if (existing != null) {
      _user = existing;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // In auth_controller.dart — update the catch blocks:

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      _user = await _repo.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':    return 'No account found for this email.';
      case 'wrong-password':    return 'Incorrect password.';
      case 'invalid-email':     return 'Please enter a valid email.';
      case 'user-disabled':     return 'This account has been disabled.';
      case 'email-already-in-use': return 'An account already exists for this email.';
      case 'weak-password':     return 'Password must be at least 6 characters.';
      case 'network-request-failed': return 'Check your internet connection.';
      default:                  return 'Something went wrong. Please try again.';
    }
  }

  Future<bool> createAccount(
      String name, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repo.createAccount(name, email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Could not create account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User → your AppUser model
  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
    );
  }

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<AppUser?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAppUser(result.user);
  }

  @override
  Future<AppUser?> createAccount(
      String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Save display name
    await result.user?.updateDisplayName(name);
    return _toAppUser(result.user);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
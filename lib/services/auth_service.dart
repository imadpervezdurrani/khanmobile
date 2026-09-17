import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  bool _isDemoLoggedIn = true;
  String _demoUserEmail = "admin@mobileshop.com";

  bool get isDemoLoggedIn => _isDemoLoggedIn;
  String get userEmail => _auth?.currentUser?.email ?? _demoUserEmail;

  void initialize() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Auth running in Demo Mode: $e");
    }
  }

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return Stream.value(null);
  }

  Future<bool> signIn(String email, String password) async {
    if (_auth != null) {
      try {
        await _auth!.signInWithEmailAndPassword(
            email: email.trim(), password: password);
        return true;
      } catch (e) {
        debugPrint("Firebase Sign-in error: $e");
        // Allow demo login fallback if credentials match
        if (email.trim() == "admin@mobileshop.com" && password == "admin123") {
          _isDemoLoggedIn = true;
          _demoUserEmail = email;
          return true;
        }
        rethrow;
      }
    } else {
      if (email.trim() == "admin@mobileshop.com" && password == "admin123") {
        _isDemoLoggedIn = true;
        _demoUserEmail = email;
        return true;
      }
      return false;
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _isDemoLoggedIn = false;
  }
}

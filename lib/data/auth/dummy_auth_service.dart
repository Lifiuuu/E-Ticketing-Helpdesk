import 'dart:async';

class DummyAuthService {
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username.isEmpty || password.isEmpty) return false;
    return true; // accept any non-empty credentials for demo
  }

  Future<bool> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username.isEmpty || email.isEmpty || password.isEmpty) return false;
    return true;
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty) return false;
    return true;
  }
}

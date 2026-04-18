import 'package:flutter/material.dart';
import '../../data/auth/dummy_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final DummyAuthService _service = DummyAuthService();

  bool _loggedIn = false;
  String? _username;
  /// role: 'user' or 'admin'
  String _role = 'user';

  bool get isLoggedIn => _loggedIn;
  String? get username => _username;
  String get role => _role;

  Future<bool> login(String username, String password) async {
    final ok = await _service.login(username, password);
    if (ok) {
      _loggedIn = true;
      _username = username;
      notifyListeners();
    }
    return ok;
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    final ok = await _service.register(username, email, password);
    return ok;
  }

  Future<bool> resetPassword(String email) async {
    final ok = await _service.resetPassword(email);
    return ok;
  }

  void logout() {
    _loggedIn = false;
    _username = null;
    notifyListeners();
  }
}

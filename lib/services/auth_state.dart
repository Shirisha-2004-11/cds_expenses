// lib/services/auth_state.dart
// Simple in-memory token store — holds the JWT after login

class AuthState {
  static String? _token;
  static String? _userName;

  static void setToken(String token, {String? userName}) {
    _token = token;
    _userName = userName;
  }

  static String? get token => _token;
  static String? get userName => _userName;

  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static void clear() {
    _token = null;
    _userName = null;
  }
}
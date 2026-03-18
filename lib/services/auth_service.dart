import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthService {
  // ─── Common headers ───────────────────────────────────────
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
      };

  // ─── Sign In ──────────────────────────────────────────────
  // POST http://192.168.182.180:8081/auth/login
  // Body: { "email": "...", "password": "..." }
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.signIn),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Invalid email or password.');
      } else if (response.statusCode == 404) {
        throw AuthException(
            message: 'Account not found. Please sign up first.');
      } else {
        throw AuthException(
          message: data['message'] ?? data['error'] ?? 'Sign in failed.',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message:
            'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────
  // POST http://192.168.182.180:8081/auth/register
  // Body: { "full_name": "...", "email": "...", "password": "..." }
  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.signUp),
            headers: _headers,
            body: jsonEncode({
              'name': fullName,       // Spring Boot field name
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else if (response.statusCode == 409) {
        throw AuthException(
            message: 'An account with this email already exists.');
      } else {
        throw AuthException(
          message: data['message'] ?? data['error'] ?? 'Sign up failed.',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message:
            'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Microsoft SSO ────────────────────────────────────────
  // POST http://192.168.182.180:8081/auth/microsoft
  // Body: { "microsoft_token": "..." }
  Future<AuthResponse> signInWithMicrosoft({
    required String microsoftToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/auth/microsoft'),
            headers: _headers,
            body: jsonEncode({'microsoft_token': microsoftToken}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        throw AuthException(
          message: data['message'] ?? 'Microsoft login failed.',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Microsoft login failed. Please try again.');
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException({required this.message, this.statusCode});
}
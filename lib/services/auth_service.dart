import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/auth_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─── Sign In ──────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.signIn),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      debugPrint('LOGIN RESPONSE: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Invalid email or password.');
      } else if (response.statusCode == 404) {
        throw AuthException(message: 'Account not found. Please sign up first.');
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
        message: 'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────
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
              'name': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else if (response.statusCode == 409) {
        throw AuthException(message: 'An account with this email already exists.');
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
        message: 'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Forgot Password — sends OTP to email ─────────────────
  // POST /auth/forgot-password
  // Body: { "email": "..." }
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.forgotPassword),
            headers: _headers,
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('FORGOT PASSWORD RESPONSE: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw AuthException(
          message: data['message'] ?? data['error'] ?? 'Failed to send OTP.',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Reset Password ───────────────────────────────────────
  // POST /auth/reset-password
  // Body: { "email": "...", "otp": "...", "password": "..." }
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.resetPassword),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'password': password,   // matches your Spring Boot field name
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('RESET PASSWORD RESPONSE: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        if (response.statusCode == 400) {
          throw AuthException(message: 'Invalid or expired OTP. Please try again.');
        }
        if (response.statusCode == 404) {
          throw AuthException(message: 'Account not found.');
        }
        throw AuthException(
          message: data['message'] ?? data['error'] ?? 'Password reset failed.',
          statusCode: response.statusCode,
        );
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Cannot connect to server. Make sure you are on the same network.',
      );
    }
  }

  // ─── Microsoft SSO ────────────────────────────────────────
  Future<AuthResponse> signInWithMicrosoft({required String microsoftToken}) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.microsoftAuth),
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
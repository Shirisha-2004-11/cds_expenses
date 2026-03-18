class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserModel user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Spring Boot commonly returns 'token' or 'accessToken' or 'access_token'
      token: json['token'] ??
          json['accessToken'] ??
          json['access_token'] ??
          '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      user: UserModel.fromJson(
        json['user'] ?? json['data'] ?? json,
      ),
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      // Spring Boot commonly returns 'name' not 'full_name'
      fullName: json['name'] ??
          json['full_name'] ??
          json['fullName'] ??
          json['username'] ??
          '',
      email: json['email'] ?? '',
    );
  }
}
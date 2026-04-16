class ApiConstants {
  static const String baseUrl = 'http://192.168.182.180:8081';

  static const String signIn         = '$baseUrl/auth/login';
  static const String signUp         = '$baseUrl/auth/register';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword  = '$baseUrl/auth/reset-password';  
  static const String refreshToken   = '$baseUrl/auth/refresh';
  static const String logout         = '$baseUrl/auth/logout';
  static const String microsoftAuth  = '$baseUrl/auth/microsoft';

  static const String microsoftClientId    = '5efbf251-d5bb-4595-97b4-9c7ddc661d1e';
  static const String microsoftTenantId    = '3473a586-677d-4216-ac29-91a55b9b642d';
  static const String microsoftRedirectUri = 'http://localhost:4200';
  static const List<String> microsoftScopes = [
    'openid', 'profile', 'email', 'User.Read',
  ];

  static const String contentType   = 'application/json';
  static const String authHeader    = 'Authorization';
  static const String bearerPrefix  = 'Bearer ';
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
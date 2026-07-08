import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  /// Ambil userId dari JWT yang tersimpan (payload `id`), tanpa perlu
  /// hit endpoint tambahan. Dipakai untuk membedakan pesan "milik saya"
  /// di layar chat.
  static Future<String?> getCurrentUserId() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map;
      return payload['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Registrasi gagal',
          statusCode: response.statusCode);
    }

    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Login gagal',
          statusCode: response.statusCode);
    }

    return data;
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otpCode': otpCode}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Verifikasi gagal',
          statusCode: response.statusCode);
    }

    return data;
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/resend-otp');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal mengirim ulang OTP',
          statusCode: response.statusCode);
    }

    return data;
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class CvService {
  static Future<List<dynamic>> getTemplates() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/cv/templates');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat template',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createCv({
    required String label,
    required String templateId,
    String? position,
    String? summary,
    List<Map<String, dynamic>> experience = const [],
    List<Map<String, dynamic>> education = const [],
    List<String> skills = const [],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/cv');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'label': label,
        'templateId': templateId,
        'position': position,
        'summary': summary,
        'experience': experience,
        'education': education,
        'skills': skills,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal membuat CV',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Uint8List> previewCv({
    required String templateId,
    String? position,
    String? summary,
    List<Map<String, dynamic>> experience = const [],
    List<Map<String, dynamic>> education = const [],
    List<String> skills = const [],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/cv/preview');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'templateId': templateId,
        'position': position,
        'summary': summary,
        'experience': experience,
        'education': education,
        'skills': skills,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(data['message'] ?? 'Gagal membuat preview',
          statusCode: response.statusCode);
    }
    return response.bodyBytes;
  }

  static Future<List<dynamic>> getMyCvs() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/cv');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat daftar CV',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }
}

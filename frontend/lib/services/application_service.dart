import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class ApplicationService {
  static Future<Map<String, dynamic>> applyToJob({
    required String jobId,
    required List<String> cvIds,
    required String contactName,
    required String contactPhone,
    String? appliedSkill,
    List<String> portfolioUrls = const [],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/applications');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'jobId': jobId,
        'cvIds': cvIds,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'appliedSkill': appliedSkill,
        'portfolioUrls': portfolioUrls,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal melamar pekerjaan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> createOffer({
    required String jobId,
    required String workerId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/applications/offer/job/$jobId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'workerId': workerId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal menawarkan pekerjaan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> getMyApplications(
      {String? type, String? keyword}) async {
    final queryParams = {
      if (type != null) 'type': type,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/applications/mine')
        .replace(queryParameters: queryParams);
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat lamaran',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<List<dynamic>> getApplicantsForJob(String jobId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/applications/job/$jobId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat pelamar',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getApplicationDetail(
      String applicationId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/applications/$applicationId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memuat detail lamaran',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> respondToApplication({
    required String applicationId,
    required String status, // 'ACCEPTED' | 'REJECTED' | 'COMPLETED'
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/applications/$applicationId/status');
    final headers = await ApiConfig.authHeaders();

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memperbarui status',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<void> cancelApplication(String applicationId) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/applications/$applicationId/cancel');
    final headers = await ApiConfig.authHeaders();

    final response = await http.patch(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal membatalkan lamaran',
          statusCode: response.statusCode);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class JobService {
  static Future<Map<String, dynamic>> searchJobs({
    String? keyword,
    String? locationArea,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': '$page',
      'limit': '$limit',
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (locationArea != null && locationArea.isNotEmpty)
        'locationArea': locationArea,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs')
        .replace(queryParameters: queryParams);
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memuat lowongan',
          statusCode: response.statusCode);
    }
    return data; // { items, pagination }
  }

  static Future<Map<String, dynamic>> getJobDetail(String jobId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memuat detail lowongan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> getMyJobs() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/mine');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat lowongan saya',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String locationArea,
    required String fullAddress,
    required num salaryAmount,
    String salaryType = 'PER_HARI',
    int totalSlot = 1,
    List<String> requirements = const [],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'locationArea': locationArea,
        'fullAddress': fullAddress,
        'salaryAmount': salaryAmount,
        'salaryType': salaryType,
        'totalSlot': totalSlot,
        'requirements': requirements,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal membuat lowongan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? locationArea,
    String? fullAddress,
    num? salaryAmount,
    String? salaryType,
    List<String>? requirements,
    String? status,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId');
    final headers = await ApiConfig.authHeaders();

    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (locationArea != null) 'locationArea': locationArea,
      if (fullAddress != null) 'fullAddress': fullAddress,
      if (salaryAmount != null) 'salaryAmount': salaryAmount,
      if (salaryType != null) 'salaryType': salaryType,
      if (requirements != null) 'requirements': requirements,
      if (status != null) 'status': status,
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal menyimpan perubahan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<void> deleteJob(String jobId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.delete(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal menghapus lowongan',
          statusCode: response.statusCode);
    }
  }
}

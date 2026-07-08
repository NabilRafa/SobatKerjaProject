import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class ProfileService {
  static Future<Map<String, dynamic>> getMyProfile() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/me');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memuat profil',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getPublicProfile(String userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/$userId');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memuat profil',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    required String location,
    String? bio,
    List<String>? skills,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/me');
    final headers = await ApiConfig.authHeaders();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'location': location,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal menyimpan perubahan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> uploadPhoto(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/me/photo');
    final headers = await ApiConfig.authHeaders();
    headers.remove(
        'Content-Type'); // multipart set content-type sendiri (dengan boundary)

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal upload foto',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> searchWorkers(
      {String? skill, String? location, int page = 1, int limit = 10}) async {
    final queryParams = {
      'page': '$page',
      'limit': '$limit',
      if (skill != null && skill.isNotEmpty) 'skill': skill,
      if (location != null && location.isNotEmpty) 'location': location,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/search/workers')
        .replace(queryParameters: queryParams);
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal mencari pekerja',
          statusCode: response.statusCode);
    }
    return data;
  }
}

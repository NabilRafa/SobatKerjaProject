import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class PortfolioService {
  static Future<Map<String, dynamic>> uploadPortfolio(File imageFile,
      {String? caption}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/portfolio');
    final headers = await ApiConfig.authHeaders();
    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    if (caption != null && caption.isNotEmpty) {
      request.fields['caption'] = caption;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal upload portofolio',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> getMyPortfolio() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/portfolio/mine');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat portofolio',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<void> deletePortfolio(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/portfolio/$id');
    final headers = await ApiConfig.authHeaders();

    final response = await http.delete(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal menghapus portofolio',
          statusCode: response.statusCode);
    }
  }
}

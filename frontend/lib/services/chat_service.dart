import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart' show ApiException;

class ChatService {
  /// Mulai (atau ambil yang sudah ada) percakapan dengan user lain.
  static Future<Map<String, dynamic>> startConversation(
      String otherUserId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chat/conversations');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'otherUserId': otherUserId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(data['message'] ?? 'Gagal memulai percakapan',
          statusCode: response.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> getMyConversations() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chat/conversations');
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat daftar chat',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<List<dynamic>> getMessages(String conversationId,
      {DateTime? since}) async {
    final queryParams = {
      if (since != null) 'since': since.toIso8601String(),
    };
    final uri = Uri.parse(
            '${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages')
        .replace(queryParameters: queryParams);
    final headers = await ApiConfig.authHeaders();

    final response = await http.get(uri, headers: headers);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(message ?? 'Gagal memuat pesan',
          statusCode: response.statusCode);
    }
    return decoded as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final uri = Uri.parse(
        '${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages');
    final headers = await ApiConfig.authHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'content': content}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(data['message'] ?? 'Gagal mengirim pesan',
          statusCode: response.statusCode);
    }
    return data;
  }
}

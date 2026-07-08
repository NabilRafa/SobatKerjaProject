import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'chat_room_screen.dart';

/// Daftar room chat milik user yang sedang login. Dipakai oleh worker
/// maupun employer -- keduanya bisa mulai chat baru lewat
/// [startAndOpenConversation] yang dipanggil dari layar lain
/// (mis. lihat pelamar, cari pekerja, detail lowongan).
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ChatService.getMyConversations();
      setState(() => _conversations = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat daftar chat');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openConversation(Map conv) {
    final otherUser = conv['otherUser'] as Map? ?? {};
    final profile = otherUser['profile'] as Map? ?? {};
    // Pakai root navigator (bukan Navigator lokal tab) supaya ChatRoomScreen
    // dibuka full-screen DI ATAS shell -- kalau tidak, bottom bar shell yang
    // melayang di luar IndexedStack bakal nutupin kotak input chat.
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            conversationId: conv['conversationId'] as String,
            otherUserName: profile['fullName'] as String? ?? 'Pengguna',
            otherUserPhotoUrl: profile['photoUrl'] as String?,
          ),
        ))
        .then((_) => _loadConversations());
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final isToday = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (isToday) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
            ),
            child: const Text('Chat',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_errorMessage!,
                                style: const TextStyle(fontFamily: 'Poppins')),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: _loadConversations,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _conversations.isEmpty
                        ? const Center(
                            child: Text('Belum ada percakapan',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textGray,
                                    fontSize: 14)),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadConversations,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: _conversations.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final conv = _conversations[index] as Map;
                                final otherUser =
                                    conv['otherUser'] as Map? ?? {};
                                final profile =
                                    otherUser['profile'] as Map? ?? {};
                                final fullName =
                                    profile['fullName'] as String? ??
                                        'Pengguna';
                                final photoUrl = profile['photoUrl'] as String?;
                                final lastMessage = conv['lastMessage'] as Map?;
                                final preview =
                                    lastMessage?['content'] as String? ??
                                        'Mulai percakapan';

                                return Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _openConversation(conv),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.border,
                                            backgroundImage: photoUrl != null
                                                ? NetworkImage(photoUrl)
                                                : null,
                                            child: photoUrl == null
                                                ? const Icon(Icons.person,
                                                    color: AppColors.textGray)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(fullName,
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textDark)),
                                                const SizedBox(height: 3),
                                                Text(preview,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .textGray)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            _formatTime(
                                                lastMessage?['createdAt']
                                                    as String?),
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                                color: AppColors.textGray),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// Helper: mulai (atau lanjutkan) percakapan dengan [otherUserId], lalu
/// langsung buka layar chat-nya. Dipanggil dari layar manapun yang butuh
/// tombol "Chat" (lihat pelamar, cari pekerja, detail lowongan, dsb).
Future<void> startAndOpenConversation(
  BuildContext context, {
  required String otherUserId,
  required String otherUserName,
  String? otherUserPhotoUrl,
}) async {
  try {
    final conversation = await ChatService.startConversation(otherUserId);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => ChatRoomScreen(
        conversationId: conversation['id'] as String,
        otherUserName: otherUserName,
        otherUserPhotoUrl: otherUserPhotoUrl,
      ),
    ));
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memulai percakapan, coba lagi')),
      );
    }
  }
}

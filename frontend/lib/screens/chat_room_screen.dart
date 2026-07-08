import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart' show ApiException, AuthService;
import '../theme/app_colors.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<dynamic> _messages = [];
  String? _myUserId;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _init();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  Future<void> _init() async {
    _myUserId = await AuthService.getCurrentUserId();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ChatService.getMessages(widget.conversationId);
      setState(() => _messages = data);
      _scrollToBottom();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat pesan');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _poll() async {
    if (_messages.isEmpty) {
      _loadMessages();
      return;
    }
    try {
      final lastCreatedAt = _messages.last['createdAt'] as String?;
      final since =
          lastCreatedAt != null ? DateTime.parse(lastCreatedAt) : null;
      final newMessages =
          await ChatService.getMessages(widget.conversationId, since: since);
      if (newMessages.isNotEmpty && mounted) {
        setState(() => _messages.addAll(newMessages));
        _scrollToBottom();
      }
    } catch (_) {
      // polling diam-diam gagal, coba lagi di siklus berikutnya
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();
    try {
      final sent = await ChatService.sendMessage(
          conversationId: widget.conversationId, content: content);
      setState(() => _messages.add(sent));
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan, coba lagi')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          _buildHeader(),
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
                                onPressed: _loadMessages,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Text('Mulai percakapan sekarang',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textGray,
                                    fontSize: 13)),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index] as Map;
                              final isMine = msg['senderId'] == _myUserId;
                              return _messageBubble(msg, isMine);
                            },
                          ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 50, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            backgroundImage: widget.otherUserPhotoUrl != null
                ? NetworkImage(widget.otherUserPhotoUrl!)
                : null,
            child: widget.otherUserPhotoUrl == null
                ? const Icon(Icons.person, color: AppColors.textGray, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.otherUserName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Map msg, bool isMine) {
    final content = msg['content'] as String? ?? '';
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: isMine ? Colors.white : AppColors.textDark),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textGray,
                        fontSize: 13.5),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _handleSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

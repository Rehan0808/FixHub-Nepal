
import 'package:fixhub_nepal/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:fixhub_nepal/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:fixhub_nepal/features/chat/data/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/services/hive_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRemoteDataSource _chatDataSource = ChatRemoteDataSource();
  final ChatLocalDataSource _localDataSource = ChatLocalDataSource();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HiveService _hiveService = HiveService();

  List<ChatMessageModel> _messages = [];
  // IDs of messages that were created locally (AI responses) — these are
  // not stored in the backend DB, so we keep them across refreshes.
  final Set<String> _localOnlyIds = {};

  bool _isLoading = true;   // only true on the very first load
  bool _isSending = false;
  bool _isOnlineMode = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages(isInitial: true);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 5 s (only when online and not busy).
    // We intentionally do NOT set _isLoading=true during poll refreshes so
    // the message list never flashes to a spinner / black screen.
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isOnlineMode && !_isLoading && !_isSending) {
        _loadMessages(isInitial: false);
      }
    });
  }

  Future<void> _loadMessages({bool isInitial = false}) async {
    if (isInitial) {
      setState(() { _isLoading = true; _errorMessage = null; });
    }

    // AI chatbot only uses local Hive messages (separate from admin chat)
    try {
      final hiveMsgs = await _localDataSource.getLocalMessages();
      for (final m in hiveMsgs) { _localOnlyIds.add(m.id); }

      setState(() {
        _messages = hiveMsgs..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _isLoading = false;
        _isOnlineMode = true;
        _errorMessage = null;
      });

      if (isInitial) _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isOnlineMode = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageText = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);

    final profileBox = _hiveService.profileBox;
    final userId = profileBox.get('userId', defaultValue: 'local_user');
    final userName = profileBox.get('userName', defaultValue: 'You');

    try {
      final chatMessages = await _chatDataSource.sendMessage(
        messageText,
        userId: userId,
        userName: userName,
      );

      // Persist every returned message (user msg + AI reply) to Hive so they
      // survive navigation away and back to this screen.
      for (final msg in chatMessages) {
        _localOnlyIds.add(msg.id);
        await _localDataSource.saveMessage(msg);
      }

      setState(() {
        for (final msg in chatMessages) {
          if (!_messages.any((m) => m.id == msg.id)) {
            _messages.add(msg);
          }
        }
        _isSending = false;
        _isOnlineMode = true;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _messageController.text = messageText,
            ),
          ),
        );
      }
      final localMessage = ChatMessageModel.createLocal(
        message: messageText,
        senderId: userId,
        senderName: userName,
        isAdmin: false,
      );
      _localOnlyIds.add(localMessage.id);
      await _localDataSource.saveMessage(localMessage);
      setState(() { _messages.add(localMessage); _isOnlineMode = false; });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'FixHub Assistant',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadMessages(isInitial: true))],
      ),
      body: Column(
        children: [
          if (!_isOnlineMode && !_isLoading && _errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.orange.withOpacity(0.1),
              child: Text(_errorMessage!, style: TextStyle(fontSize: 11, color: Colors.orange.shade700)),
            ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : _messages.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No messages yet', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Start a conversation with our AI assistant', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ]),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: _isSending
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 2))
                          : Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isMe = !message.isAdmin;
    final time = DateFormat('HH:mm').format(message.timestamp);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 16, backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.smart_toy_rounded, size: 18, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).colorScheme.primary : (Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!isMe)
                  Padding(padding: const EdgeInsets.only(bottom: 4),
                      child: Text(message.senderName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary))),
                Text(message.message, style: TextStyle(fontSize: 14, color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 10, color: isMe ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7) : Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 16, backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.primary)),
          ],
        ],
      ),
    );
  }
}

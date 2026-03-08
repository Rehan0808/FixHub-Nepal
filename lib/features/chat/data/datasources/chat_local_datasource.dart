import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';

class ChatLocalDataSource {
  static const String _boxName = 'chatMessages';
  
  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<ChatMessageModel>> getLocalMessages() async {
    try {
      final box = await _box;
      final messagesJson = box.get('messages', defaultValue: []);
      
      if (messagesJson is List) {
        return messagesJson
            .map((json) => ChatMessageModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading local messages: $e');
      return [];
    }
  }

  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      final box = await _box;
      final messages = await getLocalMessages();
      messages.add(message);
      
      await box.put(
        'messages',
        messages.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  Future<void> clearMessages() async {
    try {
      final box = await _box;
      await box.delete('messages');
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }
}

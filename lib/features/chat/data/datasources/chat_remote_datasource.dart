import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_ai_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final HiveService _hiveService = HiveService();

  String? get _token => _hiveService.profileBox.get('authToken');

  Future<List<ChatMessageModel>> getMessages() async {
    try {
      print('Fetching messages from: ${ApiEndpoints.chatMessages}');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.chatMessages),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> messagesJson;
        
        if (jsonResponse is List) {
          messagesJson = jsonResponse;
        } else if (jsonResponse['data'] is List) {
          messagesJson = jsonResponse['data'];
        } else if (jsonResponse['messages'] is List) {
          messagesJson = jsonResponse['messages'];
        } else {
          print('Unexpected response format: $jsonResponse');
          return [];
        }
        
        print('Found ${messagesJson.length} messages');
        return messagesJson.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Could not connect to server: $e');
    }
  }

  Future<List<ChatMessageModel>> sendMessage(String message, {String? userId, String? userName}) async {
    final List<ChatMessageModel> result = [];
    try {
      // 1. Add user message to chat
      final userMsg = ChatMessageModel.createLocal(
        message: message,
        senderId: userId ?? 'user',
        senderName: userName ?? 'You',
        isAdmin: false,
      );
      result.add(userMsg);

      // 2. Send to AI endpoint
      print('Sending message to AI: ${ApiAiEndpoints.aiChat}');
      final aiResponse = await http.post(
        Uri.parse(ApiAiEndpoints.aiChat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'message': message}),
      ).timeout(const Duration(seconds: 15));

      print('AI response status: ${aiResponse.statusCode}');
      print('AI response body: ${aiResponse.body}');

      if (aiResponse.statusCode == 200) {
        final jsonResponse = json.decode(aiResponse.body);
        final aiText = jsonResponse['response'] ?? jsonResponse['message'] ?? 'Sorry, I could not reply.';
        final aiMsg = ChatMessageModel.createLocal(
          message: aiText,
          senderId: 'ai_bot',
          senderName: 'FixHub Bot',
          isAdmin: true,
        );
        result.add(aiMsg);
      } else {
        final aiMsg = ChatMessageModel.createLocal(
          message: 'Sorry, I could not reply. (AI error)',
          senderId: 'ai_bot',
          senderName: 'FixHub Bot',
          isAdmin: true,
        );
        result.add(aiMsg);
      }
      return result;
    } catch (e) {
      print('Error sending message to AI: $e');
      final aiMsg = ChatMessageModel.createLocal(
        message: 'Sorry, I could not reply. (Network error)',
        senderId: 'ai_bot',
        senderName: 'FixHub Bot',
        isAdmin: true,
      );
      result.add(aiMsg);
      return result;
    }
  }
}

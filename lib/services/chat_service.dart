import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/helper.dart';

import '../model/chat_message.dart';
import '../model/chat_room.dart';

class ChatService {
  static const String baseUrl = '$API_URL/chat'; // Replace with your API URL

  static Future<Map<String, String>> _getHeaders() async {
    final token = localStorage.getItem('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get list of chat rooms for the current user
  static Future<List<ChatRoom>> getChatRooms() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ChatRoom.fromJson(json)).toList();
    } else {
      throw errorHandler(response, 'getChatRooms');
    }
  }

  // Send a message via HTTP (backup if WebSocket fails)
  static Future<ChatMessage> sendMessage(
    String roomId,
    String content,
    String messageType,
  ) async {
    final headers = await _getHeaders();
    final body = json.encode({'content': content, 'message_type': messageType});

    final response = await http.post(
      Uri.parse('$baseUrl/rooms/$roomId/messages'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ChatMessage.fromJson(json.decode(response.body));
    } else {
      throw errorHandler(response, 'sendMessage');
    }
  }

  // Get chat room details and messages
  static Future<ChatRoom> getChatRoom(String roomId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ChatRoom.fromJson(json.decode(response.body));
    } else {
      throw errorHandler(response, 'getChatRoom');
    }
  }

  // Get messages for a chat room
  static Future<List<ChatMessage>> getRoomMessages(String roomId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> messagesJson = data['messages'] ?? [];

      // Get current user ID to determine isMe property
      final userId = localStorage.getItem('userId') ?? '';

      return messagesJson.map((json) {
        final message = ChatMessage.fromJson(json);
        // Set isMe based on current user ID
        return ChatMessage(
          id: message.id,
          roomId: message.roomId,
          senderId: message.senderId,
          sender_type: message.sender_type,
          message: message.message,
          is_read: message.is_read,
          createdAt: message.createdAt,
          isMe: message.senderId == userId,
          isPayment: message.isPayment,
          paymentDetails: message.paymentDetails,
          isMap: message.isMap,
        );
      }).toList();
    } else {
      throw errorHandler(response, 'getRoomMessages');
    }
  }
}

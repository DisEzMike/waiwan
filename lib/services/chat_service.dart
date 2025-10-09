import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/utils/config.dart';

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
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rooms'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching chat rooms: $e');
      throw Exception('Failed to fetch chat rooms: $e');
    }
  }

  // Send a message via HTTP (backup if WebSocket fails)
  static Future<ChatMessage> sendMessage(String roomId, String content, String messageType) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'content': content,
        'message_type': messageType,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomId/messages'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ChatMessage.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Get chat room details and messages
  static Future<ChatRoom> getChatRoom(String roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/$roomId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ChatRoom.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch chat room: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching chat room: $e');
      throw Exception('Failed to fetch chat room: $e');
    }
  }

  // Get messages for a chat room
  static Future<List<ChatMessage>> getRoomMessages(String roomId) async {
    try {
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
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching messages: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }
}
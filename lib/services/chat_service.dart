import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/helper.dart';

import '../model/chat_message.dart';
import '../model/chat_room.dart';

class ChatService {
  static const String baseUrl = '$API_URL/chat';

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
        throw errorHandler(response, 'getChatRooms');
      }
    } catch (e) {
      debugPrint('Error in getChatRooms: $e');
      rethrow;
    }
  }

  // Get chat room details with messages
  static Future<ChatRoom> getChatRoom(String roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/$roomId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        debugPrint('Chat room response: $json');
        return ChatRoom.fromJson(json);
      } else {
        throw errorHandler(response, 'getChatRoom');
      }
    } catch (e) {
      debugPrint('Error in getChatRoom: $e');
      rethrow;
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
            senderType: message.senderType,
            senderName: message.senderName,
            message: message.message,
            isRead: message.isRead,
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
    } catch (e) {
      debugPrint('Error in getRoomMessages: $e');
      rethrow;
    }
  }

  // Send a message via HTTP (backup if WebSocket fails)
  static Future<ChatMessage> sendMessage(
    String roomId,
    String content, {
    String messageType = 'text',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'message': content,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomId/messages'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final messageData = json.decode(response.body);
        final userId = localStorage.getItem('userId') ?? '';
        
        // Create ChatMessage and set isMe
        final message = ChatMessage.fromJson(messageData);
        return ChatMessage(
          id: message.id,
          roomId: message.roomId,
          senderId: message.senderId,
          senderType: message.senderType,
          senderName: message.senderName,
          message: message.message,
          isRead: message.isRead,
          createdAt: message.createdAt,
          isMe: message.senderId == userId,
          isPayment: message.isPayment,
          paymentDetails: message.paymentDetails,
          isMap: message.isMap,
        );
      } else {
        throw errorHandler(response, 'sendMessage');
      }
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      rethrow;
    }
  }

  // Create or get chat room for a job
  static Future<ChatRoom> createOrGetChatRoom(int jobId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/$jobId/room'),
        headers: headers,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ChatRoom.fromJson(json);
      } else {
        throw errorHandler(response, 'createOrGetChatRoom');
      }
    } catch (e) {
      debugPrint('Error in createOrGetChatRoom: $e');
      rethrow;
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageHelper {
  
  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // User data management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('user_data');
    if (dataString != null) {
      try {
        return json.decode(dataString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Chat settings
  static Future<void> saveChatSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_settings', json.encode(settings));
  }

  static Future<Map<String, dynamic>?> getChatSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('chat_settings');
    if (dataString != null) {
      try {
        return json.decode(dataString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Last message timestamp for rooms
  static Future<void> saveLastMessageTime(String roomId, DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_message_$roomId', timestamp.toIso8601String());
  }

  static Future<DateTime?> getLastMessageTime(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('last_message_$roomId');
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
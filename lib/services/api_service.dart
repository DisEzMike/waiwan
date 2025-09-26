import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/elderly_person.dart';
import '../model/chat_message.dart';
import '../model/review_elderly.dart';

class ApiService {
  // Use your computer's IP address when running the FastAPI server
  static const String baseUrl = 'http://192.168.1.130:8000';
  
  // Alternative: Use localhost only when running on web or same device
  // static const String baseUrl = 'http://localhost:8000';
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// Get all elderly persons from API
  static Future<List<ElderlyPerson>> getElderlyPersons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/elderly-persons'),
        headers: headers,
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ElderlyPerson.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching elderly persons: $e');
      // Re-throw the error instead of returning empty list
      // This allows the UI to show proper error messages
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }

  /// Get specific elderly person by name
  static Future<ElderlyPerson?> getElderlyPersonByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/elderly-persons/${Uri.encodeComponent(name)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ElderlyPerson.fromJson(json);
      } else {
        throw Exception('Failed to load elderly person: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching elderly person: $e');
      return null;
    }
  }

  /// Get chat messages from API
  static Future<List<ChatMessage>> getChatMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat-messages'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      // Re-throw the error instead of returning empty list
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }

  /// Get all reviews from API
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  /// Get specific review by ID
  static Future<Review?> getReviewById(String reviewId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Review.fromJson(json);
      } else {
        throw Exception('Failed to load review: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching review: $e');
      return null;
    }
  }

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
}
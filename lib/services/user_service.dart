import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waiwan/utils/config.dart';

class UserService {
  // Use your computer's IP address when running the FastAPI server
  static const String baseUrl = '$API_URL/user';

  // Alternative: Use localhost only when running on web or same device
  // static const String baseUrl = 'http://localhost:8001/auth';

  final String accessToken;

  UserService({required this.accessToken});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  // get user profile
  Future getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/me'),
            headers: headers
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting profile: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }
}

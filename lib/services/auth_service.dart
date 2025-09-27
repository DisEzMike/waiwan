import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waiwan/utils/config.dart';

class AuthService {
  // Use your computer's IP address when running the FastAPI server
  static const String baseUrl = '$API_URL/auth';

  // Alternative: Use localhost only when running on web or same device
  // static const String baseUrl = 'http://localhost:8001/auth';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Request OTP
  static Future requestOtp(String phoneNumber) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/request-otp'),
            headers: headers,
            body: jsonEncode({'phone': phoneNumber}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error requesting OTP: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }

  // Verify OTP
  static Future verifyOtp(String phoneNumber, String otp) async {

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-otp'),
            headers: headers,
            body: jsonEncode({'phone': phoneNumber, 'otp': otp, 'role': 'user'}),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
     catch (e) {
      print('Error verifying OTP: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }

  static Future authentication(String authCode, dynamic data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl?auth_code=$authCode'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in authentication: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/helper.dart';

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
      throw errorHandler(response, 'requestOtp');
    }
  }

  // Verify OTP
  static Future verifyOtp(String phoneNumber, String otp) async {
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
      throw errorHandler(response, 'verifyOtp');
    }
  }

  static Future authentication(String authCode, dynamic data) async {
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
      throw errorHandler(response, 'authentication');
    }
  }
}

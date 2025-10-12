import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/utils/config.dart';
import 'dart:io';
import 'dart:typed_data';

class UserService {
  // Use your computer's IP address when running the FastAPI server
  static const String baseUrl = '$API_URL/user';

  // Alternative: Use localhost only when running on web or same device
  // static const String baseUrl = 'http://localhost:8001/auth';

  final String accessToken = localStorage.getItem('token') ?? '';

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  // get user profile
  Future getProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/me'), headers: headers)
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

  Future getSenior(String seniorId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$seniorId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting senior: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }

  // Upload avatar/profile image
  Future uploadAvatar(File file) async {
    try {
      final uri = Uri.parse('$baseUrl/me/avatar');
      final request =
          http.MultipartRequest('POST', uri)
            ..headers.addAll({'Authorization': 'Bearer $accessToken'})
            ..files.add(await http.MultipartFile.fromPath('avatar', file.path));

      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      throw Exception('ไม่สามารถอัปโหลดรูปได้: $e');
    }
  }

  // Upload avatar from bytes (useful for web where file path is not available)
  Future uploadAvatarBytes(Uint8List bytes, String filename) async {
    try {
      final uri = Uri.parse('$baseUrl/me/avatar');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({'Authorization': 'Bearer $accessToken'});

      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename,
        // contentType: MediaType('image', 'jpeg'), // optional
      );
      request.files.add(multipartFile);

      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading avatar bytes: $e');
      throw Exception('ไม่สามารถอัปโหลดรูปได้: $e');
    }
  }
}

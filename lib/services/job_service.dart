import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/helper.dart';

class JobService {
  static const String baseUrl = '$API_URL/job';

  final String accessToken;

  JobService({required this.accessToken});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Future createJob(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'createJob');
    }
  }
}

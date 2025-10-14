import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/helper.dart';

class JobService {
  // Use your computer's IP address when running the FastAPI server
  static const String baseUrl = '$API_URL/jobs';

  // Alternative: Use localhost only when running on web or same device
  // static const String baseUrl = 'http://localhost:8001/auth';

  final String accessToken = localStorage.getItem('token') ?? '';

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  // Get my jobs
  Future<List<MyJob>> getMyJobs() async {
    final response = await http
        .get(Uri.parse('$baseUrl/my-jobs'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      final data = jsonDecode(response.body);
      final List<dynamic> jsonList = data['jobs'];
      return jsonList.map((json) => MyJob.fromJson(json)).toList();
    } else {
      throw errorHandler(response, 'getMyJobs');
    }
  }

  // Get all jobs
  Future<List<MyJob>> getAllJobs() async {
    final response = await http
        .get(Uri.parse('$baseUrl/all'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MyJob.fromJson(json)).toList();
    } else {
      throw errorHandler(response, 'getAllJobs');
    }
  }

  // Get job by id
  Future getJobById(int jobId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/$jobId'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return JobDetail.fromJson(data);
    } else {
      throw errorHandler(response, 'getJobById');
    }
  }

  // Update job
  Future updateJob(String jobId, Map<String, dynamic> jobData) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/$jobId'),
          headers: headers,
          body: jsonEncode(jobData),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'updateJob');
    }
  }

  // Create job
  Future createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode(jobData),
          )
          .timeout(const Duration(seconds: 10)); // Increased timeout
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if response body is empty
        if (response.body.isEmpty) {
          return {'message': 'Job created successfully', 'success': true};
        }
        
        try {
          return jsonDecode(response.body);
        } catch (e) {
          // If JSON parsing fails but status is success, return success message
          return {'message': 'Job created successfully', 'success': true, 'raw_response': response.body};
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw errorHandler(response, 'createJob');
      }
    } catch (e) {
      print('Create job error: $e');
      rethrow;
    }
  }

  // Start job
  Future startJob(String jobId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/$jobId/start'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'startJob');
    }
  }

  // Complete job
  Future completeJob(String jobId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/$jobId/complete'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'completeJob');
    }
  }

  //  Invite senior to job
  Future inviteSenior(String jobId, dynamic payload) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/$jobId/invite'),
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'inviteSenior');
    }
  }

  //  Accept invitation
  Future acceptInvite(String jobId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/$jobId/accept'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'acceptInvite');
    }
  }

  //  Decline invitation
  Future declineInvite(String jobId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/$jobId/decline'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'declineInvite');
    }
  }

  // get invitations pending
  Future getPendingInvitations() async {
    final response = await http
        .get(Uri.parse('$baseUrl/applications/pending'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'getPendingInvitations');
    }
  }

  // get accepted jobs
  Future getAcceptJobs() async {
    final response = await http
        .get(Uri.parse('$baseUrl/applications/accepted'), headers: headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw errorHandler(response, 'getAcceptJobs');
    }
  }
}

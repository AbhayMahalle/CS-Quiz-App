import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // Helper to attach JWT
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // --- AUTH ENDPOINTS ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  // --- QUIZ ENDPOINTS ---
  Future<List<dynamic>> fetchQuestions(String category, int limit) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/$category?limit=$limit'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String category,
    required int score,
    required int correctAnswers,
    required int wrongAnswers,
    required int totalQuestions,
    required int timeTaken,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/submit'),
      headers: headers,
      body: jsonEncode({
        'category': category,
        'score': score,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'totalQuestions': totalQuestions,
        'timeTaken': timeTaken,
      }),
    );
    return _processResponse(response);
  }

  // --- STATS ENDPOINTS ---
  Future<Map<String, dynamic>> getStats(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/stats/$userId'),
      headers: headers,
    );
    return _processResponse(response);
  }

  // --- LEADERBOARD ENDPOINTS ---
  Future<List<dynamic>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  // Utility to process JSON response and throw errors if non-2xx
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred. Response code: ${response.statusCode}');
    }
  }
}

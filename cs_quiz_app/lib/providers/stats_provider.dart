import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result_model.dart';
import '../services/api_service.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserStatsModel _userStats = UserStatsModel();
  List<QuizResultModel> _recentResults = [];
  Map<String, double> _categoryPerformance = {};
  bool _isLoading = false;
  String? _errorMessage;

  UserStatsModel get userStats => _userStats;
  List<QuizResultModel> get recentResults => _recentResults;
  Map<String, double> get categoryPerformance => _categoryPerformance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("Not logged in");
      }

      final data = await _apiService.getStats(userId);
      _userStats = UserStatsModel.fromJson(data['userStats']);
      
      final resultsJson = List<dynamic>.from(data['recentResults'] ?? []);
      _recentResults = resultsJson.map((r) => QuizResultModel.fromJson(r)).toList();
      
      final catPerfJson = List<dynamic>.from(data['categoryPerformance'] ?? []);
      _categoryPerformance = {};
      for (var item in catPerfJson) {
         _categoryPerformance[item['category']] = (item['averageScore'] as num).toDouble();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}

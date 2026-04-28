import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';

enum QuizState { notStarted, active, finished, loading, error }

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  QuizState _quizState = QuizState.notStarted;
  String _currentCategory = '';
  String? _errorMessage;
  int _limit = 10;
  
  int _timeLeft = AppConstants.timePerQuestion; // 20s
  Timer? _timer;

  Map<String, String> _userAnswers = {}; // question id -> option
  int _correctCount = 0;
  int _wrongCount = 0;

  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizState get quizState => _quizState;
  String get currentCategory => _currentCategory;
  int get timeLeft => _timeLeft;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  Map<String, String> get userAnswers => _userAnswers;
  String? get errorMessage => _errorMessage;

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  Future<void> startQuiz(String categoryId, int limit) async {
    _quizState = QuizState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentCategory = categoryId;
      _limit = limit;
      final rawQuestions = await _apiService.fetchQuestions(categoryId, limit);
      _questions = rawQuestions.map((q) => QuestionModel.fromJson(q)).toList();
      
      _quizState = QuizState.active;
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _userAnswers.clear();
      
      _startTimer();
    } catch (e) {
      _quizState = QuizState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void _startTimer() {
    _timeLeft = AppConstants.timePerQuestion;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        submitAnswer(''); // Auto fail when time expires
      }
    });
  }

  void submitAnswer(String selectedOption) {
    if (_quizState != QuizState.active) return;
    
    final question = currentQuestion;
    if (question == null) return;
    _timer?.cancel();

    _userAnswers[question.id] = selectedOption;

    if (selectedOption == question.correctAnswer) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _startTimer();
    } else {
      _finishQuiz();
    }
    notifyListeners();
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    _quizState = QuizState.finished;

    int totalQuestions = _questions.length;
    int score = _correctCount * 10; // score mapped dynamically

    try {
      await _apiService.submitQuiz(
        category: _currentCategory,
        score: score,
        correctAnswers: _correctCount,
        wrongAnswers: _wrongCount,
        totalQuestions: totalQuestions,
        timeTaken: (totalQuestions * AppConstants.timePerQuestion) - _timeLeft, // Approx
      );
    } catch (e) {
      _errorMessage = 'Failed to submit score: ${e.toString()}';
    }

    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    _quizState = QuizState.notStarted;
    _questions = [];
    _currentQuestionIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _userAnswers.clear();
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

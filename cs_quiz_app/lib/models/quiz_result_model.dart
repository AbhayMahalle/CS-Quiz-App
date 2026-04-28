class QuizResultModel {
  final String id;
  final String category;
  final double score;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTaken; // in seconds
  final DateTime date;
  final int totalQuestions;

  QuizResultModel({
    required this.id,
    required this.category,
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTaken,
    required this.date,
    this.totalQuestions = 10,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      correctAnswers: json['correctAnswers']?.toInt() ?? 0,
      wrongAnswers: json['wrongAnswers']?.toInt() ?? 0,
      timeTaken: json['timeTaken']?.toInt() ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      totalQuestions: json['totalQuestions']?.toInt() ?? 10,
    );
  }
}

class UserStatsModel {
  int totalQuizzes;
  int totalCorrect;
  int totalWrong;
  double averageScore;
  double highestScore;
  double accuracy;

  UserStatsModel({
    this.totalQuizzes = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.averageScore = 0.0,
    this.highestScore = 0.0,
    this.accuracy = 0.0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalQuizzes: json['totalQuizzesPlayed']?.toInt() ?? 0,
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
      highestScore: (json['bestScore'] ?? 0).toDouble(),
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      totalCorrect: (json['accuracy'] ?? 0).toInt(),
      totalWrong: 100 - ((json['accuracy'] ?? 0) as num).toInt(),
    );
  }
}

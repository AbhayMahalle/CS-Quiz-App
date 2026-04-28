class QuestionModel {
  final String id;
  final String category;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;

  QuestionModel({
    required this.id,
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      questionText: json['question'] ?? 'Missing Question',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
    );
  }
}

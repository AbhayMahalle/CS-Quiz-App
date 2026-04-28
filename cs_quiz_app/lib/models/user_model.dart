class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  // Stats
  final int totalScore;
  final int quizzesPlayed;
  final double accuracy;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.totalScore = 0,
    this.quizzesPlayed = 0,
    this.accuracy = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      totalScore: json['totalScore']?.toInt() ?? 0,
      quizzesPlayed: json['quizzesPlayed']?.toInt() ?? 0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
    );
  }
}

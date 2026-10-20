class PlayLabScoreResult {
  final String sessionId;
  final String? childId;
  final String? childName;
  final int gameplayScore;
  final int knowledgeScore;
  final int totalScore;
  final int starsEarned;
  final int xpAwarded;
  final String feedbackSummary;
  final DateTime completedAt;

  PlayLabScoreResult({
    required this.sessionId,
    this.childId,
    this.childName,
    required this.gameplayScore,
    required this.knowledgeScore,
    required this.totalScore,
    required this.starsEarned,
    required this.xpAwarded,
    required this.feedbackSummary,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'childId': childId,
    'childName': childName,
    'gameplayScore': gameplayScore,
    'knowledgeScore': knowledgeScore,
    'totalScore': totalScore,
    'starsEarned': starsEarned,
    'xpAwarded': xpAwarded,
    'feedbackSummary': feedbackSummary,
    'completedAt': completedAt.toIso8601String(),
  };

  factory PlayLabScoreResult.fromJson(Map<String, dynamic> json) => PlayLabScoreResult(
    sessionId: json['sessionId']?.toString() ?? '',
    childId: json['childId']?.toString(),
    childName: json['childName']?.toString(),
    gameplayScore: (json['gameplayScore'] as num?)?.toInt() ?? 0,
    knowledgeScore: (json['knowledgeScore'] as num?)?.toInt() ?? 0,
    totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    starsEarned: (json['starsEarned'] as num?)?.toInt() ?? 0,
    xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
    feedbackSummary: json['feedbackSummary']?.toString() ?? '',
    completedAt: json['completedAt'] != null
        ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}

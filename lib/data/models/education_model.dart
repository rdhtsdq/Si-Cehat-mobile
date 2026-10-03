class EducationModel {
  final String id;
  final String title;
  final String type; // video, podcast, quiz, artikel
  final String duration;
  final String summary;
  final String contentBody;
  final String speakerOrSource;
  final String? videoUrl;
  final String? imageUrl;

  EducationModel({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.summary,
    required this.contentBody,
    this.speakerOrSource = 'Tim Edukasi Si Cehat',
    this.videoUrl,
    this.imageUrl,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    String type = (json['category'] ?? json['type'] ?? 'artikel').toString().toLowerCase();
    if (json['videoUrl'] != null && json['videoUrl'].toString().isNotEmpty) {
      type = 'video';
    }

    final readTime = json['readTimeMinutes'];
    final dur = readTime != null ? '$readTime Menit Baca' : (json['duration'] ?? '3 Menit');

    return EducationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Materi Edukasi',
      type: type,
      duration: dur,
      summary: json['summary'] ?? '',
      contentBody: json['content'] ?? json['contentBody'] ?? '',
      speakerOrSource: json['speakerOrSource'] ?? 'Kemenkes RI & IDAI',
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    List<String> opts = [];
    if (json['options'] is List) {
      opts = (json['options'] as List).map((e) => e.toString()).toList();
    }

    int correct = 0;
    if (json['answer'] != null && opts.isNotEmpty) {
      final ans = json['answer'].toString();
      final idx = opts.indexOf(ans);
      if (idx != -1) correct = idx;
    } else if (json['correctIndex'] is int) {
      correct = json['correctIndex'];
    }

    return QuizQuestion(
      question: json['question'] ?? 'Pertanyaan Kuis',
      options: opts.isNotEmpty ? opts : ['Benar', 'Salah'],
      correctIndex: correct,
      explanation: json['explanation'] ?? 'Pilihan sehat menjaga kadar gula darah tetap stabil.',
    );
  }
}

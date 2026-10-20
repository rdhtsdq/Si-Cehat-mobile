class EducationModel {
  final String id;
  final String title;
  final String type; // video, podcast, quiz, artikel, makanan
  final String duration;
  final String summary;
  final String contentBody;
  final String speakerOrSource;
  final String? videoUrl;
  final String? audioUrl;
  final String? mediaType;
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
    this.audioUrl,
    this.mediaType,
    this.imageUrl,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    String type = (json['category'] ?? json['type'] ?? 'artikel').toString().toLowerCase();
    final vidUrl = json['videoUrl']?.toString();
    final audUrl = json['audioUrl']?.toString();

    if (type == 'podcast' || (audUrl != null && audUrl.isNotEmpty)) {
      type = 'podcast';
    } else if (type == 'video' || (vidUrl != null && vidUrl.isNotEmpty)) {
      type = 'video';
    }

    final readTime = json['readTimeMinutes'];
    final dur = readTime != null ? '$readTime Menit' : (json['duration'] ?? '3 Menit');

    return EducationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Materi Edukasi',
      type: type,
      duration: dur,
      summary: json['summary'] ?? '',
      contentBody: json['content'] ?? json['contentBody'] ?? '',
      speakerOrSource: json['speakerOrSource'] ?? 'Kemenkes RI & IDAI',
      videoUrl: vidUrl,
      audioUrl: audUrl,
      mediaType: json['mediaType']?.toString(),
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

class EducationModel {
  final String id;
  final String title;
  final String type; // video, podcast, quiz
  final String duration;
  final String summary;
  final String contentBody;
  final String speakerOrSource;

  EducationModel({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.summary,
    required this.contentBody,
    this.speakerOrSource = 'Tim Edukasi Si Cehat',
  });
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
}

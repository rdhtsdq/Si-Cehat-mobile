import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/database/seed_data.dart';
import '../../data/models/education_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<QuizQuestion> _questions = SeedData.sampleQuizQuestions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _hasAnswered = false;
  int _scoreCorrect = 0;
  bool _quizFinished = false;

  void _submitAnswer(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _scoreCorrect++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kuis Edukasi Sehat',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _quizFinished ? _buildResultView() : _buildQuizQuestionView(),
        ),
      ),
    );
  }

  Widget _buildQuizQuestionView() {
    final q = _questions[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Pertanyaan
        Text(
          'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
          style: AppTypography.bodySecondary.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreenDark,
          ),
        ),
        const SizedBox(height: 12),

        // Teks Pertanyaan
        Text(
          q.question,
          style: AppTypography.titleCard.copyWith(fontSize: 18, height: 1.35),
        ),
        const SizedBox(height: 24),

        // Pilihan Jawaban Besar
        Expanded(
          child: ListView.separated(
            itemCount: q.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final isChosen = _selectedOption == i;
              final isCorrect = i == q.correctIndex;

              Color bg = AppColors.fieldBackground;
              Color border = Colors.transparent;
              Color textColor = AppColors.textDark;

              if (_hasAnswered) {
                if (isCorrect) {
                  bg = const Color(0xFFE8F5E9);
                  border = AppColors.primaryGreen;
                  textColor = AppColors.primaryGreenDark;
                } else if (isChosen && !isCorrect) {
                  bg = const Color(0xFFFFEBEE);
                  border = AppColors.accentRed;
                  textColor = AppColors.accentRed;
                }
              } else if (isChosen) {
                bg = AppColors.paleGreenBg;
                border = AppColors.primaryGreen;
              }

              return InkWell(
                onTap: _hasAnswered ? null : () => _submitAnswer(i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isChosen ? AppColors.primaryGreen : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isChosen ? AppColors.primaryGreen : AppColors.divider,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(65 + i), // A, B, C, D
                          style: TextStyle(
                            color: isChosen ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          q.options[i],
                          style: AppTypography.bodyRegular.copyWith(
                            color: textColor,
                            fontWeight: isChosen || (_hasAnswered && isCorrect)
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Feedback Penjelasan saat sudah dijawab
        if (_hasAnswered) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penjelasan:',
                  style: AppTypography.badgeText.copyWith(
                    color: AppColors.primaryGreenDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.explanation,
                  style: AppTypography.bodySecondary.copyWith(
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: _currentIndex < _questions.length - 1 ? 'Pertanyaan Berikutnya' : 'Lihat Hasil Kuis',
            onPressed: _nextQuestion,
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildResultView() {
    final percent = ((_scoreCorrect / _questions.length) * 100).toInt();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.paleGreenBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              '$percent%',
              style: AppTypography.headingScreen.copyWith(
                fontSize: 32,
                color: AppColors.primaryGreenDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Persentase kuis berlabel "Jawaban benar", bukan risiko diabetes
          Text(
            'Jawaban Benar: $_scoreCorrect dari ${_questions.length} Soal',
            style: AppTypography.titleCard.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Skor ini menunjukkan tingkat pemahaman materi kebiasaan sehat keluarga Anda.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 36),
          PrimaryButton(
            text: 'Kembali ke Edukasi',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

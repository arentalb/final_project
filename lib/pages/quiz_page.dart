import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/quesion.dart';
import '../models/word.dart';
import '../services/quiz_service.dart';
import '../services/words_service.dart';
import 'package:forui/forui.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final WordsService _wordService = WordsService();
  final QuizService _quizService = QuizService();

  List<Question> questions = [];
  Map<String, Word> wordsMap = {};
  List<int> selectedAnswers = [];
  int currentQuestionIndex = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWordsAndGenerateQuiz();
  }

  Future<void> _loadWordsAndGenerateQuiz() async {
    try {
      final words = await _wordService.getWordsToReviewToday().first;

      if (words.isEmpty) {
        setState(() {
          errorMessage = "هیچ وشەیەک نیە بۆ تاقیکردنەوەی ئەمڕۆ";
          isLoading = false;
        });
        return;
      }

      wordsMap = {for (var word in words) word.id: word};
      questions = await _quizService.generateQuestions(words);
      selectedAnswers = List.filled(questions.length, -1);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "هەلەیەک ڕویدا لە کاتی بارکردنی وشەکان: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final colorScheme = context.theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "پرسیار ${currentQuestionIndex + 1} لە ${questions.length}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "مانای ${currentQuestion.questionText} چیە؟",
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 24),
              ...List.generate(currentQuestion.choices.length, (index) {
                bool isSelected = selectedAnswers[currentQuestionIndex] == index;
                return GestureDetector(
                  onTap: () => _onAnswerSelected(index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentQuestion.choices[index],
                      style: TextStyle(fontSize: 18, color: isSelected ? Colors.white : Colors.black),
                    ),
                  ),
                );
              }),
              const Spacer(),
              FButton(
                onPress: () {
                  if (selectedAnswers[currentQuestionIndex] != -1) {
                    _onNextPressed();
                  }
                },
                label: Text(
                  currentQuestionIndex == questions.length - 1 ? "ناردن" : "دواتر",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAnswerSelected(int index) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = index;
    });
  }

  void _onNextPressed() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    List<String> correctWordIds = _quizService.getCorrectWordIds(questions, selectedAnswers, wordsMap);
    List<String> incorrectWordIds = _quizService.getIncorrectWordIds(questions, selectedAnswers, wordsMap);
    int score = correctWordIds.length;

    _quizService.submitExam(correctWordIds,incorrectWordIds);
    showDialog(
      context: context,
      builder: (_)=>FDialog(
        direction: Axis.vertical,
        title: const Text('تاقیکردنەوەی ئەمڕۆش تەواو'),
        body:  Text('لە کۆی ${questions.length} توانیت پرسیار ${score} بە دەست بهێنیت '),
        actions: [
          FButton(
            label: const Text('باش'),
            onPress: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      )

    );
  }
}

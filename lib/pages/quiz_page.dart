import 'package:flutter/material.dart';
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
  final _wordService = WordsService();
  final _quizService = QuizService();

  List<QuizQuestion> questions = [];
  Map<String, Word> wordsMap = {};
  List<int> selectedAnswers = [];
  int currentQuestionIndex = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
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
      questions = _quizService.generateQuestions(words);
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
        appBar: AppBar(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("نتیجە"),
        content: Text(
          "تۆ $score لە ${questions.length} دەروونت\n"
              "وشە دروستەکان: $correctWordIds\n"
              "وشە هەڵەکان: $incorrectWordIds",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("باشە"),
          ),
        ],
      ),
    );
  }
}

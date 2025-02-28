import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/quiz_question.dart';
import 'package:flutter_test_app/models/quiz_result.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:flutter_test_app/utils/quiz_maker_utils.dart';
import 'package:forui/forui.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _wordService = WordsService();

  List<QuizQuestion> questions = [];
  Map<String, Word> wordsMap = {};
  List<int> selectedAnswers = [];
  int currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Word>>(
      stream: _wordService.getWordsToReviewToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error loading quiz data: ${snapshot.error}")),
          );
        }

        final words = snapshot.data ?? [];
        if (words.isEmpty) {
          return Scaffold(
            body: Center(child: Text("هیچ وشەیەک نیە بۆ تاقیکردنەوەی ئەمڕۆ")),
          );
        }

        if (questions.isEmpty) {
          _prepareQuiz(words);
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
      },
    );
  }

  void _prepareQuiz(List<Word> words) {
    wordsMap = {for (var word in words) word.id: word};
    questions = generateQuizQuestions(words);
    selectedAnswers = List.filled(questions.length, -1);
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
    List<QuizResult> quizResults = [];
    for (int i = 0; i < questions.length; i++) {
      quizResults.add(
        QuizResult(
          question: questions[i],
          selectedAnswerIndex: selectedAnswers[i],
        ),
      );
    }

    List<String> correctWordIds = [];
    List<String> incorrectWordIds = [];
    for (var result in quizResults) {
      if (result.isCorrect(wordsMap)) {
        correctWordIds.add(result.wordId);
      } else {
        incorrectWordIds.add(result.wordId);
      }
    }

    int score = correctWordIds.length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("نتیجە"),
        content: Text(
          "تۆ $score لە ${questions.length} دەروونت\n"
              "Correct IDs: $correctWordIds\n"
              "Incorrect IDs: $incorrectWordIds",
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

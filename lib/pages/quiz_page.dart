import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/quiz_question.dart';
import 'package:flutter_test_app/models/quiz_result.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:forui/forui.dart';

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Map<String, Word> wordsMap;

  const QuizPage({
    Key? key,
    required this.questions,
    required this.wordsMap,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;

  late List<int> selectedAnswers;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.questions.length, -1);
    print(widget.questions);
    print(widget.wordsMap);
  }

  void _onAnswerSelected(int index) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = index;
    });
  }

  void _onNextPressed() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {

      List<QuizResult> quizResults = [];
      for (int i = 0; i < widget.questions.length; i++) {
        quizResults.add(
          QuizResult(
            question: widget.questions[i],
            selectedAnswerIndex: selectedAnswers[i],
          ),
        );
      }

      List<String> correctWordIds = [];
      List<String> incorrectWordIds = [];
      for (var result in quizResults) {
        if (result.isCorrect(widget.wordsMap)) {
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
            "تۆ $score لە ${widget.questions.length} دەروونت\n"
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

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];
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
                "پرسیار ${currentQuestionIndex + 1} لە ${widget.questions.length}",
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
                      color: isSelected ? colorScheme.primary: colorScheme.secondary,
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
              FButton(onPress: (){
                selectedAnswers[currentQuestionIndex] == -1 ? null : _onNextPressed();
              }, label:Text(
                currentQuestionIndex == widget.questions.length - 1 ? "ناردن" : "دواتر",
                style: const TextStyle(fontSize: 18),
              ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

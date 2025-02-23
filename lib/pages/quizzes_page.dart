import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:flutter_test_app/utils/quiz_maker_utils.dart';
import 'package:forui/forui.dart';
import 'quiz_page.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  final _wordService = WordsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Word>>(
      future: _wordService.getTodayQuizWords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        final words = snapshot.data!;
        final wordsMap = {for (var word in words) word.id: word};
        final quizQuestions = generateQuizQuestions(words);

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "تاقی کردنەوەی ئەمڕۆ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      FButton(
                          onPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  questions: quizQuestions,
                                  wordsMap: wordsMap,
                                ),
                              ),
                            );
                          },
                          label: Text("دەستپێ کردن")),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("تکایە یەکێک لە تاقیکردنەوەکان هەلبژێرە"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

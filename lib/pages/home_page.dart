import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/quiz_page.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _wordService = WordsService();
  int todayWordsCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayWordsCount();
  }

  Future<void> _loadTodayWordsCount() async {
    final count = await _wordService.getSizeOfWordsThatWeShouldReviewToday();
    setState(() {
      todayWordsCount = count;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "تاقی کردنەوەی ئەمڕۆ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    FButton(
                      onPress: todayWordsCount < 1
                          ? null
                          : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QuizPage(),
                          ),
                        );
                      },
                      label: Text(
                        todayWordsCount < 1
                            ? "تاقی کردنەوە نیە"
                            : "دەستپێ کردن ($todayWordsCount)",
                      ),
                    ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text("تکایە یەکێک لە تاقیکردنەوەکان هەلبژێرە"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

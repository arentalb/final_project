import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:flutter_test_app/pages/quiz_page.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';
import 'package:flip_card/flip_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _wordService = WordsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  StreamBuilder<int>(
                    stream: _wordService.getSizeOfWordsToReviewToday(),
                    builder: (context, sizeSnapshot) {
                      if (sizeSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final todayWordsCount = sizeSnapshot.data ?? 0;

                      return FButton(
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
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Word>>(
                stream: _wordService.getWordsToReviewToday(),
                builder: (context, wordsSnapshot) {
                  if (wordsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final todayWords = wordsSnapshot.data ?? [];

                  if (todayWords.isEmpty) {
                    return const Center(child: Text("هیچ وشەیەک نیە بۆ ئەمڕۆ"));
                  }

                  return ListView.builder(
                    itemCount: todayWords.length,
                    itemBuilder: (context, index) {
                      final word = todayWords[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: FlipCard(
                          direction: FlipDirection.HORIZONTAL,
                          front: _buildCard(word.englishWord, "کلیک بکە بۆ پیشاندانی واتا"),
                          back: _buildCard(word.kurdishWord, "بگەڕێوە بۆ وشەکە"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

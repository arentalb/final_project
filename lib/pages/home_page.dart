import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:flutter_test_app/pages/quiz_page.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';
import 'package:flip_card/flip_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF02AABD), Color(0xFF00CDAC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "تاقی کردنەوەی ئەمڕۆ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    FutureBuilder<int>(
                      future: _wordService.getSizeOfWordsToReviewToday(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingAnimationWidget.inkDrop(
                            color: Colors.white,
                            size: 30,
                          );
                        }
                        final todayWordsCount = snapshot.data ?? 0;
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
                            style: TextStyle(
                              color: todayWordsCount < 1
                                  ? Colors.white
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    }
                    final todayWords = snapshot.data ?? [];

                    if (todayWords.isEmpty) {
                      return const Center(
                        child: Text(
                          "هیچ وشەیەک نیە بۆ ئەمڕۆ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: todayWords.length,
                      itemBuilder: (context, index) {
                        final cardKey = GlobalKey<FlipCardState>();
                        final word = todayWords[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: FlipCard(
                            key: cardKey,
                            direction: FlipDirection.HORIZONTAL,
                            front: _buildCard(
                              text: word.englishWord,
                              subtitle: "کلیک بکە بۆ پیشاندانی واتا",
                              backgroundColor: Colors.white,
                              onFlip: () => cardKey.currentState?.toggleCard(),
                            ),
                            back: _buildCard(
                              text: word.kurdishWord,
                              subtitle: "بگەڕێوە بۆ وشەکە",
                              backgroundColor: Colors.white,
                              onFlip: () => cardKey.currentState?.toggleCard(),
                            ),
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
      ),
    );
  }

  Widget _buildCard({
    required String text,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback onFlip,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: onFlip,
                icon: const Icon(Icons.flip_camera_android, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

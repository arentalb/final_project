import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/word.dart';
import 'package:flutter_test_app/pages/create_new_word_page.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

class WordsPage extends StatefulWidget {
  const WordsPage({Key? key}) : super(key: key);

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final _wordService = WordsService();

  Widget _buildBoxStepIndicator(int boxNumber) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final int step = index + 1;
        final bool isActive = step == boxNumber;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a modern look.
      body:  SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and "New Word" button.
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "وشەکان",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  FButton(
                    label: const Text('وشەی تازە'),
                    onPress: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateNewWordPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Word list.
            Expanded(
              child: StreamBuilder<List<Word>>(
                stream: _wordService.getAllWords(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final words = snapshot.data ?? [];
                  if (words.isEmpty) {
                    return const Center(
                      child: Text(
                        "هیچ وشەیەکت نیە بۆ پشاندان",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      final formattedDate = DateFormat('dd/MM/yyyy')
                          .format(word.nextReviewDate);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Word details (Kurdish and English)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            word.kurdishWord,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            word.englishWord,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Date display and step indicator.
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildBoxStepIndicator(word.boxNumber),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
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
    );
  }
}

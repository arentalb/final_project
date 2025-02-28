import 'package:cloud_firestore/cloud_firestore.dart';
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
                    "وشەکان",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Expanded(
              child: StreamBuilder<List<Word>>(
                stream: _wordService.getAllWords(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final words = snapshot.data ?? [];
                  if (words.isEmpty) {
                    return const Center(child: Text("No words available"));
                  }

                  return ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      final formattedDate = DateFormat('dd/MM/yyyy').format(word.nextReviewDate);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    word.kurdishWord,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    word.englishWord,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (i) {
                                      final reverseIndex = 4 - i;
                                      return Icon(
                                        Icons.all_inbox,
                                        size: 20,
                                        color: reverseIndex < word.boxNumber ? Colors.blue : Colors.grey,
                                      );
                                    }),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}

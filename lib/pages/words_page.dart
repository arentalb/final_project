import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/create_new_word_page.dart';
import 'package:forui/forui.dart';

class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

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
                  // am buttona ka clickman le krd pagey CreateNewWordPage man bo akatawa ba shewazek ka buttoneky haya rwy krdota dwawa
                  // ka atwanyn ba asany bgareynawa era
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
              child: Center(
                child: Text("وشەکان"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

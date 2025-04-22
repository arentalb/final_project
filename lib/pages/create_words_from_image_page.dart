// lib/pages/create_words_from_image_page.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test_app/services/dictionary_service.dart';
import 'package:flutter_test_app/services/words_service.dart';

/// Holds the original English word and its Kurdish translation
class ExtractedWord {
  final String original;
  String? translation;
  ExtractedWord(this.original, {this.translation});
}

class CreateWordsFromImagePage extends StatefulWidget {
  const CreateWordsFromImagePage({Key? key}) : super(key: key);

  @override
  State<CreateWordsFromImagePage> createState() => _CreateWordsFromImagePageState();
}

class _CreateWordsFromImagePageState extends State<CreateWordsFromImagePage> {
  final ImagePicker _picker = ImagePicker();
  // final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final DictionaryService _dictionaryService = DictionaryService();
  final WordsService _wordsService = WordsService();

  bool _isProcessing = false;
  Uint8List? _imageBytes;
  List<ExtractedWord> _extractedWords = [];

  @override
  void dispose() {
    // _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImageAndExtract() async {
    setState(() {
      _isProcessing = true;
      _imageBytes = null;
      _extractedWords.clear();
    });

    Uint8List? bytes;
    String? path;
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result == null || result.files.first.bytes == null) {
          setState(() => _isProcessing = false);
          return;
        }
        bytes = result.files.first.bytes!;
      } else {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 80,
        );
        if (picked == null) {
          setState(() => _isProcessing = false);
          return;
        }
        path = picked.path;
        bytes = await picked.readAsBytes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵە لە هەڵبژاردنی وێنە: $e')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    setState(() => _imageBytes = bytes);

    // OCR
    String rawText ="Hello , my name is Ahmad and I am a student";
    try {
      if (kIsWeb) {
        // rawText = await _dictionaryService.extractText(bytes!);
      } else {
        // final inputImage = InputImage.fromFilePath(path!);
        // final result = await _textRecognizer.processImage(inputImage);
        // rawText = result.text;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵە لە OCR: $e')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (rawText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ دەقێک نەدۆزرایەوە')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    //  ➤ Extract English words
    final regex = RegExp(r'[A-Za-z]+');
    final matches = regex.allMatches(rawText).map((m) => m.group(0)!).toSet();

    //  ➤ For each English word, fetch Kurdish meaning
    for (final word in matches) {
      final item = ExtractedWord(word);
      setState(() => _extractedWords.add(item));

      try {
        final kurdish = await _dictionaryService.fetchKurdishMeaning(word);
        setState(() => item.translation = kurdish);
      } catch (_) {
        setState(() => item.translation = null);
      }
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _saveAll() async {
    int successCount = 0;
    for (final item in _extractedWords) {
      try {
        await _wordsService.addNewWord(item.original, item.translation ?? '');
        successCount++;
      } catch (_) {}
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$successCount وشە زیاد کران')),
    );
    setState(() {
      _extractedWords.clear();
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('وەرگرتنی وشە لە وێنە'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FButton(
                label: const Text('هەڵبژاردنی وێنە و دۆزینەوە'),
                onPress: _pickImageAndExtract,
                style: FButtonStyle.primary,
              ),
              const SizedBox(height: 16),
              if (_isProcessing) const CircularProgressIndicator(),
              if (_imageBytes != null) ...[
                const SizedBox(height: 16),
                Image.memory(_imageBytes!, height: 200),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: _extractedWords.isEmpty
                    ? const Center(child: Text('هیچ وشەیەک نەدۆزرایەوە'))
                    : ListView.builder(
                  itemCount: _extractedWords.length,
                  itemBuilder: (ctx, i) {
                    final w = _extractedWords[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(w.original),
                        subtitle: w.translation != null
                            ? Text(w.translation!)
                            : const Text('...'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _extractedWords.removeAt(i));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_extractedWords.isNotEmpty) ...[
                const SizedBox(height: 8),
                FButton(
                  label: const Text('زیادکردنی هەموو وشەکان'),
                  onPress: _saveAll,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';

class WordItem {
  String text;
  String translation;
  bool isTranslating;
  bool isSelected;
  WordItem({
    required this.text,
    this.translation = '',
    this.isTranslating = true,
    this.isSelected = false,
  });
}

class CreateWordsFromImagePage extends StatefulWidget {
  const CreateWordsFromImagePage({Key? key}) : super(key: key);

  @override
  State<CreateWordsFromImagePage> createState() => _CreateWordsFromImagePageState();
}

class _CreateWordsFromImagePageState extends State<CreateWordsFromImagePage> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final GoogleTranslator _translator = GoogleTranslator();
  final WordsService _wordsService = WordsService();

  bool _isProcessing = false;
  Uint8List? _imageBytes;
  List<WordItem> _items = [];

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImageAndRecognize() async {
    setState(() {
      _isProcessing = true;
      _imageBytes = null;
      _items.clear();
    });

    Uint8List? bytes;
    String? path;
    try {
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
    } catch (e) {
      debugPrint('Image pick error: $e');
      setState(() => _isProcessing = false);
      return;
    }

    setState(() {
      _imageBytes = bytes;
    });

    String rawText = '';
    try {
      final inputImage = InputImage.fromFilePath(path!);
      final RecognizedText result = await _textRecognizer.processImage(inputImage);
      rawText = result.text;
      print('Recognized text: $rawText');
    } catch (e) {
      debugPrint('OCR error: $e');
    }

    final words = rawText
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _items = words.map((w) => WordItem(text: w)).toList();
      _isProcessing = false;
    });

    for (var i = 0; i < _items.length; i++) {
      _translateWord(i);
    }
  }

  Future<void> _translateWord(int index) async {
    setState(() => _items[index].isTranslating = true);
    try {
      final translation = await _translator.translate(_items[index].text, to: 'ckb');
      setState(() {
        _items[index].translation = translation.text;
      });
    } catch (e) {
      debugPrint('Translate error for "${_items[index].text}": $e');
    } finally {
      setState(() => _items[index].isTranslating = false);
    }
  }

  Future<bool> _editItemDialog(int index) async {
    final controllerText = TextEditingController(text: _items[index].text);
    final controllerTrans = TextEditingController(text: _items[index].translation);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllerText,
              decoration: const InputDecoration(labelText: 'English'),
            ),
            TextField(
              controller: controllerTrans,
              decoration: const InputDecoration(labelText: 'Kurdish'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items[index].text = controllerText.text;
                _items[index].translation = controllerTrans.text;
              });
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نوسین لە وێنەوە'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FButton(
              onPress: _pickImageAndRecognize,
              label: const Text('وێنەیەک دیاری بکە '),
            ),
            const SizedBox(height: 16),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator()),
            if (_imageBytes != null) ...[
              Image.memory(_imageBytes!, height: 200),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) => _editItemDialog(index),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isSelected,
                            onChanged: (checked) {
                              setState(() {
                                item.isSelected = checked ?? false;
                              });
                            },
                          ),
                          title: Text(item.text),
                          subtitle: item.isTranslating
                              ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(item.translation),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FButton(
                onPress: () async {
                  int successCount = 0;
                  for (var item in _items) {
                    if (item.isSelected) {
                      if (item.translation.isEmpty && !item.isTranslating) {
                        final idx = _items.indexOf(item);
                        await _translateWord(idx);
                      }
                      try {
                        await _wordsService.addNewWord(item.text, item.translation);
                        successCount++;
                      } catch (e) {
                        debugPrint('Failed to save ${item.text}: $e');
                      }
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('وشەکان زیاد کرا')),
                  );
                  setState(() {
                    _items.clear();
                    _imageBytes = null;
                  });
                },
                label: const Text('زیاد کرا'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

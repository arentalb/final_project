import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/dictionary_service.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';

class ExtractedWord {
  final String kurdish;
  String? english;

  ExtractedWord(this.kurdish, {this.english});
}

class CreateNewWordPage extends StatefulWidget {
  const CreateNewWordPage({Key? key}) : super(key: key);

  @override
  State<CreateNewWordPage> createState() => _CreateNewWordPageState();
}

class _CreateNewWordPageState extends State<CreateNewWordPage> {
  final WordsService _wordsService = WordsService();
  final DictionaryService _dictionaryService = DictionaryService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _kurdishWordController = TextEditingController();
  final TextEditingController _bulkTextController = TextEditingController();

  String? _kurdishMeaning;
  bool _isFetching = false;
  bool isBulkMode = false;

  List<ExtractedWord> _extractedWords = [];

  /// Fetch Kurdish meaning from English
  void _fetchWordData(String text) async {
    if (text.isEmpty) return;
    setState(() => _isFetching = true);
    try {
      final meaning = await _dictionaryService.fetchKurdishMeaning(text);
      setState(() {
        _kurdishMeaning = meaning;
        _isFetching = false;
      });
    } catch (e) {
      setState(() {
        _kurdishMeaning = null;
        _isFetching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵە لە وەرگرتنی واتا: $e')),
      );
    }
  }

  /// Save a single word
  void _createNewWord() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _wordsService.addNewWord(
          _englishWordController.text.trim(),
          _kurdishWordController.text.trim(),
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('وشەکە زیاد کرا')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('هەڵە: $e')),
        );
      }
    }
  }

  /// Extract words and fetch meanings
  void _extractWordsFromParagraph() async {
    final text = _bulkTextController.text;
    final regex = RegExp(r'[\u0600-\u06FF]+');
    final matches = regex.allMatches(text).map((m) => m.group(0)!).toSet().toList();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('هیچ وشەیەک نەدۆزرایەوە')),
        );
      return;
    }

    setState(() => _extractedWords.clear());

    for (final word in matches) {
      final item = ExtractedWord(word);
      setState(() => _extractedWords.add(item));

      try {
        final meaning = await _dictionaryService.fetchEnglishMeaning(word);
        setState(() {
          item.english = meaning;
        });
      } catch (_) {
        setState(() {
          item.english = null;
        });
      }
    }
  }

  /// Save all extracted words
  void _saveExtractedWordsToDatabase() async {
    int successCount = 0;

    for (final item in _extractedWords) {
      try {
        await _wordsService.addNewWord(item.english ?? '', item.kurdish);
        successCount++;
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$successCount وشە زیاد کران')),
    );

    setState(() {
      _extractedWords.clear();
      _bulkTextController.clear();
    });
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: FButton(
            label: const Text('زیادکردنی وشە'),
            onPress: () =>{
              setState(() {
                isBulkMode = false;
              })
            },
            style: isBulkMode ? FButtonStyle.secondary : FButtonStyle.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FButton(
            label: const Text('زیادکردنی دەق'),
            onPress: () =>{
              setState(() {
                isBulkMode = true;
              })
            },
            style: isBulkMode ? FButtonStyle.primary : FButtonStyle.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildKurdishMeaningDisplay() {
    if (_isFetching) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (_kurdishMeaning == null || _kurdishMeaning!.isEmpty) {
      return const Center(child: Text('هیچ واتایەک نەدۆزرایەوە'));
    } else {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('واتاکان',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_kurdishMeaning!),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSingleWordForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('وشە بە ئینگلیزی'),
          const SizedBox(height: 8),
          FTextField(
            controller: _englishWordController,
            hint: 'Boat',
            onChange: _fetchWordData,
            validator: (value) =>
            value == null || value.isEmpty ? 'وشەی ئینگلیزی بنووسە' : null,
          ),
          const SizedBox(height: 16),
          _buildKurdishMeaningDisplay(),
          const SizedBox(height: 8),
          const Text('واتا بە کوردی'),
          const SizedBox(height: 8),
          FTextField(
            controller: _kurdishWordController,
            hint: 'بەلەم',
            validator: (value) =>
            value == null || value.isEmpty ? 'وشەی کوردی بنووسە' : null,
          ),
          const SizedBox(height: 16),
          FButton(
            label: const Text('زیادکردن'),
            onPress: _createNewWord,
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedWordsSection() {
    if (_extractedWords.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('وشەکانت:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _extractedWords.length,
          itemBuilder: (context, index) {
            final item = _extractedWords[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(item.kurdish),
                subtitle: item.english != null
                    ? Text(item.english!)
                    : const Text('...'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => _extractedWords.removeAt(index));
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FButton(
          label: const Text('زیادکردنی وشەکان'),
          onPress: _saveExtractedWordsToDatabase,
        ),
      ],
    );
  }

  Widget _buildBulkWordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('دەقەکان بە کوردی'),
        const SizedBox(height: 8),
        FTextField.multiline(
          controller: _bulkTextController,
          maxLines: 6,
          hint: 'بۆ نموونە:\nمن بەلەمێکم هەیە\nئەم درەختە گەورەیە',
        ),
        const SizedBox(height: 16),
        FButton(
          label: const Text('دۆزینەوەی وشە'),
          onPress: _extractWordsFromParagraph,
        ),
        const SizedBox(height: 24),
        _buildExtractedWordsSection(),
      ],
    );
  }

  @override
  void dispose() {
    _englishWordController.dispose();
    _kurdishWordController.dispose();
    _bulkTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleButtons(),
              const SizedBox(height: 24),
              isBulkMode ? _buildBulkWordForm() : _buildSingleWordForm(),
            ],
          ),
        ),
      ),
    );
  }
}

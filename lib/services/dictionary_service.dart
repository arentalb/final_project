// lib/services/dictionary_service.dart
import 'package:translator/translator.dart';

/// A service for translating words between Kurdish (Sorani) and English
class DictionaryService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// Translate a single English word to Kurdish (Central Kurdish)
  Future<String> fetchKurdishMeaning(String word) async {
    try {
      final result = await _translator.translate(word, to: 'ckb');
      return result.text;
    } catch (e) {
      print('Error translating "$word" to Kurdish: $e');
      rethrow;
    }
  }

  /// Translate a single Kurdish (Sorani) word to English
  Future<String> fetchEnglishMeaning(String word) async {
    try {
      final result = await _translator.translate(word, to: 'en');
      return result.text;
    } catch (e) {
      print('Error translating "$word" to English: $e');
      rethrow;
    }
  }
}

import 'package:translator/translator.dart';

class DictionaryService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> fetchKurdishMeaning(String word) async {
    try {
      final result = await _translator.translate(word, to: 'ckb');
      return result.text;
    } catch (e) {
      print('Error translating "$word" to Kurdish: $e');
      rethrow;
    }
  }

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

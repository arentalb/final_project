

// lib/services/dictionary_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// A service for translating words and images between English and Kurdish (Sorani)
class DictionaryService {
  //────────────────────────────────────────────────────────────────────────────
  // API configuration
  //────────────────────────────────────────────────────────────────────────────
  static const String _apiKey = 'AIzaSyCHdUEFQDV_Sh8Z1ZEFQ8hnv3CM6VBe5Lg';
  static final String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';
  static final String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent?key=$_apiKey';

  /// Tracks the latest translate call to prevent race-condition fallout.
  int _lastRequestId = 0;

  DictionaryService();

  //────────────────────────────────────────────────────────────────────────────
  // Public API (with race-condition guard)
  //────────────────────────────────────────────────────────────────────────────

  /// Translate a single English word to Kurdish (Sorani).
  Future<String> fetchKurdishMeaning(String word) async {
    final callId = ++_lastRequestId;
    try {
      final result = await _translateWord(word, from: 'English', to: 'Kurdish (Sorani)');
      if (callId != _lastRequestId) {
        print('Discarding outdated Kurdish translation for "$word"');
        throw StateError('Outdated response');
      }
      return result;
    } catch (e, st) {
      print('Error in fetchKurdishMeaning: $e\n$st');
      rethrow;
    }
  }

  /// Translate a single Kurdish (Sorani) word to English.
  Future<String> fetchEnglishMeaning(String word) async {
    final callId = ++_lastRequestId;
    try {
      final result = await _translateWord(word, from: 'Kurdish (Sorani)', to: 'English');
      if (callId != _lastRequestId) {
        print('Discarding outdated English translation for "$word"');
        throw StateError('Outdated response');
      }
      return result;
    } catch (e, st) {
      print('Error in fetchEnglishMeaning: $e\n$st');
      rethrow;
    }
  }




  //────────────────────────────────────────────────────────────────────────────
  // New: Translate a block of text via Gemini (no OCR)
  Future<String> translateTextBlock({
    required String text,
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse(_geminiUrl);
    final prompt = '''
Translate the following text from \$from to \$to:

"""
\$text
"""
Respond with ONLY the translated text.
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt.trim()}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.0,
        'maxOutputTokens': 512,
      },
    });

    final resp = await _postWithRetry(
      uri,
      payload,
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw HttpException(
        'Translation API error: \${resp.statusCode} – \${resp.body}',
        uri: uri,
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final translated = (data['candidates'] as List)
        .first['content']['parts']
        .first['text'] as String?;
    if (translated == null || translated.trim().isEmpty) {
      throw FormatException('Empty translation for text block');
    }
    return translated.trim();
  }

  //────────────────────────────────────────────────────────────────────────────
  // Private HTTP with retry logic
  //────────────────────────────────────────────────────────────────────────────

  Future<http.Response> _postWithRetry(
      Uri uri,
      String body, {
        Map<String, String>? headers,
        int retries = 3,
      }) async {
    http.Response response;
    for (int attempt = 1; attempt <= retries; attempt++) {
      response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode != 429) return response;
      await Future.delayed(const Duration(seconds: 5));
    }
    return http.post(uri, headers: headers, body: body);
  }

  //────────────────────────────────────────────────────────────────────────────
  // Private helpers
  //────────────────────────────────────────────────────────────────────────────

  Future<String> _translateWord(
      String word, {
        required String from,
        required String to,
      }) async {
    final uri = Uri.parse(_geminiUrl);
    final prompt = '''
Translate the SINGLE word "$word" from $from to $to.
Respond with EXACTLY the translated word and NOTHING else.
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt.trim()}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.0,
        'maxOutputTokens': 3,
      },
    });

    final response = await _postWithRetry(
      uri,
      payload,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      print('Translation API error: \${response.statusCode} - \${response.body}');
      throw HttpException(
        'Translation API error: \${response.statusCode}',
        uri: uri,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (data['candidates'] as List)
        .first['content']['parts']
        .first['text'] as String?;

    if (text == null || text.trim().isEmpty) {
      print('Empty translation for "$word"');
      throw FormatException('Empty translation for "$word"');
    }

    return text.trim();
  }


}

import 'quiz_question.dart';
import 'word.dart';

class QuizResult {
  final QuizQuestion question;
  final int selectedAnswerIndex;

  QuizResult({
    required this.question,
    required this.selectedAnswerIndex,
  });

  bool isCorrect(Map<String, Word> wordsMap) {
    final correctWord = wordsMap[question.wordId];
    if (correctWord == null) return false;
    return question.choices[selectedAnswerIndex] == correctWord.englishWord;
  }

  String get wordId => question.wordId;
}

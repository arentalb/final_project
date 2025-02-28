import '../models/quesion.dart';
import '../models/word.dart';
import 'words_service.dart';

class QuizService {
  final WordsService _wordsService = WordsService();

  Future<List<Question>> generateQuestions(List<Word> words) async {
    List<Question> questions = [];

    for (var word in words) {
      final otherWords = await _wordsService.getRandomWordsExcluding(word.id, count: 3);
      final choices = [word.englishWord, ...otherWords.map((w) => w.englishWord)];
      choices.shuffle();

      questions.add(Question(
        wordId: word.id,
        questionText: word.kurdishWord,
        choices: choices,
      ));
    }

    return questions;
  }

  List<String> getCorrectWordIds(List<Question> questions, List<int> selectedAnswers, Map<String, Word> wordsMap) {
    final correct = <String>[];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedChoice = question.choices[selectedAnswers[i]];
      if (selectedChoice == wordsMap[question.wordId]?.englishWord) {
        correct.add(question.wordId);
      }
    }

    return correct;
  }

  List<String> getIncorrectWordIds(List<Question> questions, List<int> selectedAnswers, Map<String, Word> wordsMap) {
    final incorrect = <String>[];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedChoice = question.choices[selectedAnswers[i]];
      if (selectedChoice != wordsMap[question.wordId]?.englishWord) {
        incorrect.add(question.wordId);
      }
    }

    return incorrect;
  }
}

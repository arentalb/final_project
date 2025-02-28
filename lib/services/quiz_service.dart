import 'package:flutter_test_app/models/quesion.dart';

import '../models/word.dart';


class QuizService {
  List<Question> generateQuestions(List<Word> words) {
    return words.map((word) {
      return Question(
        wordId: word.id,
        questionText: word.kurdishWord,
        choices: _getShuffledChoices(word, words),
      );
    }).toList();
  }

  List<String> _getShuffledChoices(Word correctWord, List<Word> allWords) {
    final choices = [correctWord.englishWord];

    allWords.where((w) => w.id != correctWord.id).take(3).forEach((w) {
      choices.add(w.englishWord);
    });

    choices.shuffle();
    return choices;
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

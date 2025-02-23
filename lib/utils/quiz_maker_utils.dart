import 'package:flutter_test_app/models/quiz_question.dart';
import 'package:flutter_test_app/models/word.dart';


List<QuizQuestion> generateQuizQuestions(List<Word> words) {
  List<QuizQuestion> questions = [];

  int numberOfQuestions = words.length < 5 ? words.length : 5;

  for (int i = 0; i < numberOfQuestions; i++) {
    Word word = words[i];

    String questionText =word.kurdishWord;

    List<String> choices = [word.englishWord];

    for (int j = 0; j < words.length && choices.length < 4; j++) {
      if (j == i) continue;
      choices.add(words[j].englishWord);
    }

    while (choices.length < 4) {
      choices.add("دیاری نەکراوە");
    }

    choices.shuffle();

    questions.add(QuizQuestion(
      wordId: word.id,
      questionText: questionText,
      choices: choices,
    ));
  }

  return questions;
}

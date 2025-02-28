import '../models/quesion.dart';
import '../models/word.dart';
import 'words_service.dart';
import 'package:flutter_test_app/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

int _getOffsetForBox(int boxNumber) {
  switch (boxNumber) {
    case 1:
      return 1; // Tomorrow
    case 2:
      return 3; // After 3 days
    case 3:
      return 7; // After a week
    case 4:
      return 14; // After 2 weeks
    case 5:
      return 30; // After a month
    default:
      return 30;
  }
}

class QuizService {
  final WordsService _wordsService = WordsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _userWordsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found");
    }
    return _firestore.collection('users').doc(user.uid).collection('words');
  }

  Future<void> submitExam(List<String> correctAnswerWordIds, List<String> incorrectAnswerWordIds) async {
    final batch = FirebaseFirestore.instance.batch();
    final userWordsCollection = _userWordsCollection;

    for (final wordId in correctAnswerWordIds) {
      final docRef = userWordsCollection.doc(wordId);
      final doc = await docRef.get();
      if (!doc.exists) continue;

      final currentBox = (doc['boxNumber'] as num?)?.toInt() ?? 1;
      final nextBox = currentBox + 1;

      int offsetDays = _getOffsetForBox(nextBox);
      final nextReviewDate = getDateWithOffset(offsetDays: offsetDays);

      batch.update(docRef, {
        'boxNumber': nextBox,
        'lastReviewed': Timestamp.now(),
        'nextReviewDate': Timestamp.fromDate(nextReviewDate),
        'reviewCount': FieldValue.increment(1),
      });
    }

    for (final wordId in incorrectAnswerWordIds) {
      final docRef = userWordsCollection.doc(wordId);

      final nextReviewDate = getDateWithOffset(offsetDays: 1);

      batch.update(docRef, {
        'boxNumber': 1,
        'lastReviewed': Timestamp.now(),
        'nextReviewDate': Timestamp.fromDate(nextReviewDate),
        'reviewCount': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }


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

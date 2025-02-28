import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/utils/date_utils.dart';
import 'package:flutter_test_app/models/word.dart';

class WordsService {
  final CollectionReference wordsCollection =
  FirebaseFirestore.instance.collection('words');

  Future<void> addNewWord(String englishWord, String kurdishWord) async {
    try {
      await wordsCollection.add({
        'englishWord': englishWord,
        'kurdishWord': kurdishWord,
        "boxNumber": 1,
        "lastReviewed": null,
        "nextReviewDate": getDateWithOffset(offsetDays: 1),
        "reviewCount": 0,
      });
    } catch (error) {
      print("Failed to add word: $error");
    }
  }

  Stream<List<Word>> getAllWords() {
    return wordsCollection
        .orderBy('nextReviewDate', descending: false)
        .snapshots()
        .map(_mapSnapshotToWords);
  }

  Stream<List<Word>> getWordsToReviewToday() {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay = Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    return wordsCollection
        .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
        .where('nextReviewDate', isLessThan: endOfDay)
        .snapshots()
        .map(_mapSnapshotToWords);
  }

  Stream<int> getSizeOfWordsToReviewToday() {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay = Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    return wordsCollection
        .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
        .where('nextReviewDate', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  List<Word> _mapSnapshotToWords(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Word(
        id: doc.id,
        englishWord: data['englishWord'] ?? '',
        kurdishWord: data['kurdishWord'] ?? '',
        boxNumber: (data['boxNumber'] as num?)?.toInt() ?? 0,
        lastReviewed: (data['lastReviewed'] as Timestamp?)?.toDate() ?? DateTime.now(),
        nextReviewDate: (data['nextReviewDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test_app/utils/date_utils.dart';
import 'package:flutter_test_app/models/word.dart';

//in firebase it stored like this
// /users/{userId}/words/{wordId}

class WordsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper to get the current user's words collection path
  CollectionReference get _userWordsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found");
    }
    return _firestore.collection('users').doc(user.uid).collection('words');
  }

  Future<void> addNewWord(String englishWord, String kurdishWord) async {
    try {
      await _userWordsCollection.add({
        'englishWord': englishWord,
        'kurdishWord': kurdishWord,
        "boxNumber": 1,
        "lastReviewed": null,
        "nextReviewDate": getDateWithOffset(),
        "reviewCount": 0,
      });
    } catch (error) {
      print("Failed to add word: $error");
    }
  }

  Stream<List<Word>> getAllWords() {
    return _userWordsCollection
        .orderBy('nextReviewDate', descending: false)
        .snapshots()
        .map(_mapSnapshotToWords);
  }

  Stream<List<Word>> getWordsToReviewToday() {
    final today = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay =
        Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    return _userWordsCollection
        .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
        .where('nextReviewDate', isLessThan: endOfDay)
        .snapshots()
        .map(_mapSnapshotToWords);
  }

  Stream<int> getSizeOfWordsToReviewToday() {
    final today = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay =
        Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    return _userWordsCollection
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
        lastReviewed:
            (data['lastReviewed'] as Timestamp?)?.toDate() ?? DateTime.now(),
        nextReviewDate:
            (data['nextReviewDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<List<Word>> getRandomWordsExcluding(String excludedWordId,
      {int count = 3}) async {
    final snapshot = await _userWordsCollection.get();
    final allWords = snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Word(
            id: doc.id,
            englishWord: data['englishWord'] ?? '',
            kurdishWord: data['kurdishWord'] ?? '',
            boxNumber: (data['boxNumber'] as num?)?.toInt() ?? 0,
            lastReviewed: (data['lastReviewed'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            nextReviewDate: (data['nextReviewDate'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
          );
        })
        .where((word) => word.id != excludedWordId)
        .toList();

    allWords.shuffle();

    return allWords.take(count).toList();
  }
}

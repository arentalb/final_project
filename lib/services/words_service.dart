import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/utils/date_utils.dart';
import 'package:flutter_test_app/models/word.dart';

class WordsService {
  // ama la rey amawa ka wakw away FireAuth nia
  // lera ema esh lagal database akain
  // databasekash ema esh lagal collectiony words akain ka lera "words" yawmana pey
  // wata harkat am varaiably wordsCollection bangkaynawa awa ema datkary datay naw collectiony words akain
  CollectionReference wordsCollection =
      FirebaseFirestore.instance.collection('words');

  Future<void> addNewWord(String englishWord, String kurdishWord) async {
    try {
      // aw collection  bang akainawaw dwatr functiony addy lasar bangakain
      final word = await wordsCollection.add({
        'englishWord': englishWord,
        'kurdishWord': kurdishWord,
        // sarata ka wshayak drwstakain abet la boxy 1 a bet
        "boxNumber": 1,
        "lastReviewed": null,
        // ama lera am functionaman bangkrdwa ka ema pewista la katy drwstkrdny har wshayaki tazaya aw wshaya newxt review datakay bxayan bayani
        // chenka lentier box wa eshakat
        "nextReviewDate": getDateWithOffset(offsetDays: 1),
        "reviewCount": 0,
      });
      print(word);
    } catch (error) {
      print("Failed to add words: $error");
    }
  }

  Stream<QuerySnapshot> getTodayWordsStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // bo wargrtny aw wshanay amro pewista bixwenet amana bangakaynawa ka amw dwanayn haya :
    // reviewCount yaksana ba  0
    // nextReviewDate la bayni amrow bayanyaya katakay
    return wordsCollection.snapshots();
    // .where('reviewCount', isEqualTo: 0)
    // .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
    // .where('nextReviewDate', isLessThan: endOfDay)
    // .snapshots();
  }

  Future<List<Word>> getWordsThatWeShouldReviewToday() async {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay = Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    final snapshot = await wordsCollection
        // .where('reviewCount', isEqualTo: 0)
        .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
        .where('nextReviewDate', isLessThan: endOfDay)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Word(
        id: doc.id,
        englishWord: data['englishWord'] ?? '',
        kurdishWord: data['kurdishWord'] ?? '',
      );
    }).toList();
  }
  Future<int> getSizeOfWordsThatWeShouldReviewToday() async {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final endOfDay = Timestamp.fromDate(startOfDay.toDate().add(const Duration(days: 1)));

    final snapshot = await wordsCollection
        .where('reviewCount', isEqualTo: 0)
        .where('nextReviewDate', isGreaterThanOrEqualTo: startOfDay)
        .where('nextReviewDate', isLessThan: endOfDay)
        .get();


    return snapshot.size;
  }

}

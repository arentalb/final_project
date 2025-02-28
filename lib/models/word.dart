class Word {
  final String id;
  final String englishWord;
  final String kurdishWord;
  final int boxNumber;
  final DateTime lastReviewed;
  final DateTime nextReviewDate;
  final int reviewCount;

  Word({
    required this.id,
    required this.englishWord,
    required this.kurdishWord,
    required this.boxNumber,
    required this.lastReviewed,
    required this.nextReviewDate,
    required this.reviewCount,
  });


}

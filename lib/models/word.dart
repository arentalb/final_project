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

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      englishWord: json['englishWord'] as String,
      kurdishWord: json['kurdishWord'] as String,
      boxNumber: json['boxNumber'] as int,
      lastReviewed: DateTime.parse(json['lastReviewed'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      reviewCount: json['reviewCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishWord': englishWord,
      'kurdishWord': kurdishWord,
      'boxNumber': boxNumber,
      'lastReviewed': lastReviewed.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'reviewCount': reviewCount,
    };
  }
}

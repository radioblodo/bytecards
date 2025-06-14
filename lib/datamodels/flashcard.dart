class Flashcard {
  final int? id; // ← New: nullable ID
  final String question;
  final String answer;
  final bool isMature;
  final bool isYoung;
  final int? difficulty;

  Flashcard({
    this.id,
    required this.question,
    required this.answer,
    this.isMature = false,
    this.isYoung = false,
    this.difficulty,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'question': question,
      'answer': answer,
      'isMature': isMature ? 1 : 0,
      'isYoung': isYoung ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (difficulty != null) {
      map['difficulty'] = difficulty;
    }
    return map;
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as int?, // ← pull in the DB id
      question: map['question'] as String,
      answer: map['answer'] as String,
      isMature: (map['isMature'] ?? 0) == 1,
      isYoung: (map['isYoung'] ?? 0) == 1,
      difficulty: map['difficulty'] as int?,
    );
  }
}

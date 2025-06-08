class Flashcard {
  final int? id; // ← New: nullable ID
  final String question;
  final String answer;

  Flashcard({this.id, required this.question, required this.answer});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'question': question, 'answer': answer};
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as int?, // ← pull in the DB id
      question: map['question'] as String,
      answer: map['answer'] as String,
    );
  }
}

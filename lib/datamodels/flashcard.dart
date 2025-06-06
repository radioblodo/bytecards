class Flashcard {
  String question; 
  String answer; 

  // constructor of Flashcard 
  Flashcard({
    required this.question, 
    required this.answer,
  }); 

  // convert flashcard to map to store 
  Map<String, dynamic> toMap() {
    return {
      'question': question, 
      'answer': answer, 
    };
  }

  //convert from map to flashcard 
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      question: map['question'], 
      answer: map['answer'],
    );
  }
}
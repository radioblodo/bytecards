import 'flashcard.dart'; 

class Deck {
  String deckId; 
  String title; 
  List<Flashcard> flashcards; 
  int color; 

  // constructor of Deck 
  Deck({
    required this.deckId,
    required this.title, 
    required this.flashcards, 
    this.color = 0xe1e3e1
  }); 

  // convert deck to map to store 
  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId, 
      'title': title, 
      'flashcards': flashcards.map((card)=> card.toMap()).toList(),
      'color': color, 
    };
  }

  // convert from map to deck 
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      deckId: map['deckId'], 
      title: map['title'], 
      flashcards: (map['flashcards'] as List).map((card) => Flashcard.fromMap(card)).toList(), 
      color: map['color'] ?? 0xFF42A5F5
    );
  }
}
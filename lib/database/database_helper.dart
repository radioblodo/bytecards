import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/datamodels/flashcard.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  // Function 1: Database Getter 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Function 2: Initialize Database 
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'bytecards.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Function 3: Creates Tables 
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        deckId TEXT PRIMARY KEY,
        title TEXT,
        color INTEGER DEFAULT 0xFF42A5F5
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deckId TEXT,
        question TEXT,
        answer TEXT,
        FOREIGN KEY(deckId) REFERENCES decks(deckId) ON DELETE CASCADE
      )
    ''');
  }

  // Function 4: Insert a new deck
  Future<void> insertDeck(Deck deck) async {
    final db = await database;
    await db.insert('decks', {
      'deckId': deck.deckId,
      'title': deck.title,
      'color': deck.color, 
    }, 
    conflictAlgorithm: ConflictAlgorithm.replace, // prevent duplicate IDs
    );
  }

  // Fetch all decks
  Future<List<Deck>> getDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> decksData = await db.query('decks');

    List<Deck> decks = [];
    for (var deck in decksData) {
      decks.add(Deck(
        deckId: deck['deckId'],
        title: deck['title'],
        color: deck['color'], // to make the color change persistent
        flashcards: await getFlashcards(deck['deckId']),
      ));
    }
    return decks;
  }

  Future<void> updateDeckColor(String deckId, int color) async {
  final db = await database;
  await db.update(
    'decks',
    {'color': color},
    where: 'deckId = ?',
    whereArgs: [deckId],
  );
}

  // Insert a flashcard into a deck
  Future<void> insertFlashcard(Flashcard flashcard, String deckId) async {
    final db = await database;
    await db.insert('flashcards', {
      'deckId': deckId,
      'question': flashcard.question,
      'answer': flashcard.answer,
    });
  }

  // Fetch all flashcards for a specific deck
  Future<List<Flashcard>> getFlashcards(String deckId) async {
    final db = await database;
    final List<Map<String, dynamic>> flashcardsData =
        await db.query('flashcards', where: 'deckId = ?', whereArgs: [deckId]);

    return flashcardsData.map((flashcard) => Flashcard.fromMap(flashcard)).toList();
  }

  Future<void> deleteDeck(String deckId) async {
    final db = await database; 
    await db.delete(
      'decks',
      where: 'deckId = ?',
      whereArgs: [deckId], 
    ); 
  }
}

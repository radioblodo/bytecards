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

    return await openDatabase(path, version: 1, onCreate: _onCreate);
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

    await db.execute('''
  CREATE TABLE flashcard_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flashcardId INTEGER,
    review_time TEXT,
    FOREIGN KEY(flashcardId) REFERENCES flashcards(id) ON DELETE CASCADE
  );
''');
  }

  // Function 4: Insert a new deck
  Future<void> insertDeck(Deck deck) async {
    final db = await database;
    await db.insert(
      'decks',
      {'deckId': deck.deckId, 'title': deck.title, 'color': deck.color},
      conflictAlgorithm: ConflictAlgorithm.replace, // prevent duplicate IDs
    );
  }

  // Fetch all decks
  Future<List<Deck>> getDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> decksData = await db.query('decks');

    List<Deck> decks = [];
    for (var deck in decksData) {
      decks.add(
        Deck(
          deckId: deck['deckId'],
          title: deck['title'],
          color: deck['color'], // to make the color change persistent
          flashcards: await getFlashcards(deck['deckId']),
        ),
      );
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

  /// Inserts a flashcard and returns the new row’s `id`.
  Future<int> insertFlashcard(Flashcard flashcard, String deckId) async {
    final db = await database;
    return await db.insert('flashcards', {
      'deckId': deckId,
      'question': flashcard.question,
      'answer': flashcard.answer,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Returns all flashcards in that deck, now with their DB `id`.
  Future<List<Flashcard>> getFlashcards(String deckId) async {
    final db = await database;
    final rows = await db.query(
      'flashcards',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
    return rows.map((r) => Flashcard.fromMap(r)).toList();
  }

  Future<void> deleteDeck(String deckId) async {
    final db = await database;
    await db.delete('decks', where: 'deckId = ?', whereArgs: [deckId]);
  }

  // in DatabaseHelper:
  Future<void> insertReview(int flashcardId, DateTime when) async {
    final db = await database;
    await db.insert('flashcard_reviews', {
      'flashcardId': flashcardId,
      'review_time': when.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReviewStats() async {
    final db = await database;
    // Count reviews per day for last 7 days
    return await db.rawQuery('''
    SELECT date(review_time) AS day,
           COUNT(*) AS reviewed
    FROM flashcard_reviews
    WHERE review_time >= date('now','-6 days')
    GROUP BY day
    ORDER BY day ASC;
  ''');
  }
}

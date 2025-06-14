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
        color INTEGER DEFAULT 0xFF4A45C4
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deckId TEXT,
        question TEXT,
        answer TEXT,
        isYoung INTEGER DEFAULT 0,
        isMature INTEGER DEFAULT 0, 
        FOREIGN KEY(deckId) REFERENCES decks(deckId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
  CREATE TABLE flashcard_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flashcardId INTEGER,
    review_time TEXT,
    difficulty INTEGER, 
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
      'isYoung': flashcard.isYoung ? 1 : 0,
      'isMature': flashcard.isMature ? 1 : 0,
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
  Future<void> insertReview(
    int flashcardId,
    DateTime when,
    int difficulty,
  ) async {
    final db = await database;
    await db.insert('flashcard_reviews', {
      'flashcardId': flashcardId,
      'review_time': when.toIso8601String(),
      'difficulty': difficulty,
    });
  }

  Future<int> getTodayReviewCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) AS count 
      FROM flashcard_reviews
      WHERE date(review_time) = date('now')
      ''');

    return result.first['count'] as int? ?? 0;
  }

  // Future<List<Map<String, dynamic>>> getReviewStats() async {
  //   final db = await database;
  //   // Count reviews per day for last 7 days
  //   return await db.rawQuery('''
  //   SELECT date(review_time) AS day,
  //          COUNT(*) AS reviewed
  //   FROM flashcard_reviews
  //   WHERE review_time >= date('now','-6 days')
  //   GROUP BY day
  //   ORDER BY day ASC;
  // ''');
  // }

  Future<List<int>> getFutureDueData() async {
    final db = await database;

    // Build list of 30 days: today + 1 to today + 30
    final Map<String, int> dayCounts = {
      for (int i = 1; i <= 30; i++)
        DateTime.now().add(Duration(days: i)).toIso8601String().split('T')[0]:
            0,
    };

    // Get the latest review per flashcard
    final result = await db.rawQuery('''
    SELECT flashcardId, MAX(review_time) as last_review_time, difficulty
    FROM flashcard_reviews
    GROUP BY flashcardId
  ''');

    for (var row in result) {
      final String? lastReviewed = row['last_review_time'] as String?;
      final int? difficulty = row['difficulty'] as int?;

      if (lastReviewed == null || difficulty == null) continue;

      DateTime lastReviewDate = DateTime.parse(lastReviewed);
      int daysToAdd;

      // Simple SRS rule
      switch (difficulty) {
        case 1:
          daysToAdd = 3;
          break; // Easy
        case 2:
          daysToAdd = 2;
          break; // Medium
        case 3:
          daysToAdd = 1;
          break; // Hard
        default:
          continue;
      }

      final dueDate = lastReviewDate.add(Duration(days: daysToAdd));
      final dueKey = dueDate.toIso8601String().split('T')[0];

      if (dayCounts.containsKey(dueKey)) {
        dayCounts[dueKey] = dayCounts[dueKey]! + 1;
      }
    }

    return dayCounts.values.toList();
  }

  Future<Map<String, int>> getCardCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN isMature = 1 THEN 1 ELSE 0 END) AS mature,
        SUM(CASE WHEN isYoung = 1 THEN 1 ELSE 0 END) AS young,
        SUM(CASE WHEN isMature = 0 AND isYoung = 0 THEN 1 ELSE 0 END) AS new
      FROM flashcards
      ''');

    final row = result.first;
    return {
      'mature': (row['mature'] ?? 0) as int,
      'young': (row['young'] ?? 0) as int,
      'new': (row['new'] ?? 0) as int,
    };
  }

  Future<Map<DateTime, int>> getReviewHeatmapData() async {
    final db = await database;
    final raw = await db.rawQuery('''
      SELECT review_time, COUNT(*) AS total
      FROM flashcard_reviews
      GROUP BY date(review_time)
      ''');

    final Map<DateTime, int> data = {};
    for (var row in raw) {
      DateTime date = DateTime.parse(row['review_time'] as String).toLocal();
      final key = DateTime(date.year, date.month, date.day);
      data[key] = (row['total'] ?? 0) as int;
    }

    return data;
  }

  Future<Map<String, int>> getReviewDifficultyCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT difficulty, COUNT(*) as count
      FROM flashcard_reviews
      GROUP BY difficulty 
      ''');

    Map<String, int> difficultyMap = {'Easy': 0, 'Medium': 0, 'Hard': 0};

    for (var row in result) {
      int difficulty = (row['difficulty'] ?? 0) as int;
      int count = row['count'] as int;
      if (difficulty == 1) difficultyMap['Easy'] = count;
      if (difficulty == 2) difficultyMap['Medium'] = count;
      if (difficulty == 3) difficultyMap['Hard'] = count;
    }

    return difficultyMap;
  }

  Future<Map<String, int>> getReviewIntervalStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        strftime('%w', review_time) as weekday, 
        COUNT(*) as count
      FROM flashcard_reviews
      GROUP BY weekday
      ''');

    Map<String, int> intervalMap = {
      'Sun': 0,
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
    };

    for (var row in result) {
      String weekday = row['weekday'].toString();
      int count = (row['count'] ?? 0) as int;
      switch (weekday) {
        case '0':
          intervalMap['Sun'] = count;
          break;
        case '1':
          intervalMap['Mon'] = count;
          break;
        case '2':
          intervalMap['Tue'] = count;
          break;
        case '3':
          intervalMap['Wed'] = count;
          break;
        case '4':
          intervalMap['Thu'] = count;
          break;
        case '5':
          intervalMap['Fri'] = count;
          break;
        case '6':
          intervalMap['Sat'] = count;
          break;
      }
    }

    return intervalMap;
  }
}

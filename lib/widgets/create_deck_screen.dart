import 'package:flutter/material.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/database/database_helper.dart'; // Import your SQLite helper

class CreateDeckScreen extends StatefulWidget {
  @override
  _CreateDeckScreenState createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final TextEditingController _deckNameController = TextEditingController();

  void _saveDeck() async {
    String deckName = _deckNameController.text.trim();
    if (deckName.isEmpty) return;

    // Create a new deck instance
    Deck newDeck = Deck(
      deckId: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      title: deckName,
      flashcards: [], // Empty flashcards initially
    );

    // Save to SQLite (or SharedPreferences/Firebase)
    await DatabaseHelper.instance.insertDeck(newDeck);

    // Go back to Home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Deck')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deckNameController,
              decoration: InputDecoration(
                labelText: "Deck Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDeck,
              child: const Text("Create Deck"),
            ),
          ],
        ),
      ),
    );
  }
}

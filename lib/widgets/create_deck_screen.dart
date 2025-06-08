import 'package:flutter/material.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';

class CreateDeckScreen extends StatefulWidget {
  @override
  _CreateDeckScreenState createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final TextEditingController _deckNameController = TextEditingController();

  void _saveDeck() async {
    String deckName = _deckNameController.text.trim();
    if (deckName.isEmpty) return;

    Deck newDeck = Deck(
      deckId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: deckName,
      flashcards: [],
    );

    await DatabaseHelper.instance.insertDeck(newDeck);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.createDeck)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deckNameController,
              decoration: InputDecoration(
                labelText: loc.deckName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDeck,
              child: Text(loc.createDeckButton),
            ),
          ],
        ),
      ),
    );
  }
}

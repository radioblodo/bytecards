import 'package:flutter/material.dart';
import 'package:bytecards/datamodels/flashcard.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/pages/add_flashcard_screen.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';

class EditDeckScreen extends StatefulWidget {
  final Deck deck;

  const EditDeckScreen({Key? key, required this.deck}) : super(key: key);

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  List<Flashcard> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final cards = await DatabaseHelper.instance.getFlashcards(
      widget.deck.deckId!,
    );
    setState(() {
      _flashcards = cards;
    });
  }

  void _editFlashcardDialog(Flashcard card) {
    final loc = AppLocalizations.of(context)!;
    final questionController = TextEditingController(text: card.question);
    final answerController = TextEditingController(text: card.answer);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.editCard),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(labelText: loc.question),
                ),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(labelText: loc.answer),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = card.copyWith(
                    question: questionController.text,
                    answer: answerController.text,
                  );
                  await DatabaseHelper.instance.updateFlashcard(updated);
                  Navigator.pop(context);
                  _loadFlashcards();
                },
                child: Text(loc.save),
              ),
            ],
          ),
    );
  }

  void _deleteFlashcard(Flashcard card) async {
    await DatabaseHelper.instance.deleteFlashcard(card.id!);
    _loadFlashcards();
  }

  void _addFlashcard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlashcardScreen(deckId: widget.deck.deckId!),
      ),
    ).then((_) => _loadFlashcards());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deck.title} ${loc.editDeck}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFlashcard,
            tooltip: loc.addFlashcard,
          ),
        ],
      ),
      body:
          _flashcards.isEmpty
              ? Center(child: Text(loc.noCardsInDeck))
              : ListView.builder(
                itemCount: _flashcards.length,
                itemBuilder: (context, index) {
                  final card = _flashcards[index];
                  return ListTile(
                    title: Text(card.question),
                    subtitle: Text(card.answer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editFlashcardDialog(card),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFlashcard(card),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:bytecards/datamodels/flashcard.dart';
import '../l10n/generated/app_localizations.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String deckId;
  const AddFlashcardScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _questionFocusNode = FocusNode();

  void _saveFlashcard() async {
    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();
    if (question.isEmpty || answer.isEmpty) return;

    final newCard = Flashcard(question: question, answer: answer);
    final newId = await DatabaseHelper.instance.insertFlashcard(
      newCard,
      widget.deckId,
    );

    _questionController.clear();
    _answerController.clear();
    FocusScope.of(context).requestFocus(_questionFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.addFlashcard)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              focusNode: _questionFocusNode,
              decoration: InputDecoration(labelText: loc.question),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: loc.answer),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFlashcard,
              child: Text(loc.saveFlashcard),
            ),
          ],
        ),
      ),
    );
  }
}

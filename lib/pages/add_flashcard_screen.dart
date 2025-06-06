import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:bytecards/datamodels/flashcard.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String deckId;
  const AddFlashcardScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  void _saveFlashcard() async {
    String question = _questionController.text.trim();
    String answer = _answerController.text.trim();
    if (question.isEmpty || answer.isEmpty) return;

    Flashcard newFlashcard = Flashcard(question: question, answer: answer);
    await DatabaseHelper.instance.insertFlashcard(newFlashcard, widget.deckId);

    Navigator.pop(context); // Return to Deck Detail Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: "Question"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: "Answer"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFlashcard,
              child: const Text("Save Flashcard"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bytecards/pages/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'add_flashcard_screen.dart'; // For manual card addition
import '../database/database_helper.dart';
import 'package:bytecards/datamodels/flashcard.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;
  const DeckDetailScreen({Key? key, required this.deck}) : super(key: key);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  void _pickDocument() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['pdf', 'txt', 'docx']
      );
      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        print("Selected file: $filePath");
        _generateFlashcardsFromAI(filePath);
      }
    }catch(e) {
      print("Error picking file: $e"); 
    }
  }

  void _generateFlashcardsFromAI(String filePath) async {
    // TODO: Implement AI logic for generating flashcards
    print("Processing file for AI-based flashcard generation...");
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ Aligns everything to the center
          children: [
            // ✅ "Practice Now" Button (Centered Above)
            _practiceButton("Practice Now", Icons.play_arrow, () async {
              List<Flashcard> flashcards = await DatabaseHelper.instance.getFlashcards(widget.deck.deckId);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => PracticeScreen(flashcards: flashcards),)
              );
            }),
            const SizedBox(height: 20), // ✅ Space between "Practice Now" and the two buttons
            // ✅ Row for the Two Other Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ Centers horizontally
              children: [
                _buildButton("Manually Add Cards", Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFlashcardScreen(deckId: widget.deck.deckId),
                    ),
                  );
                }),
                const SizedBox(width: 20), // ✅ Space between the two buttons
                _buildButton("Generate Cards Using AI", Icons.auto_awesome, _pickDocument),
              ],
            ),
          ],
        ),
      ),
    );
  }

    Widget _practiceButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox.square(
      dimension: 120, // ✅ Ensures a square shape
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ✅ Rounded edges
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ Center icon & text
          children: [
            Icon(icon, size: 40), // ✅ Play icon
            const SizedBox(height: 8), // ✅ Space between icon & text
            Text(
              title,
              textAlign: TextAlign.center, // ✅ Centered text
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 140,
      height: 180, 
      child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 16),
              softWrap: true, 
              overflow: TextOverflow.visible,
              ),
          )
        ],
      ),
    )
    );
  }
}

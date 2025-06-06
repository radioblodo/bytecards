import 'package:flutter/material.dart';
import 'package:bytecards/datamodels/flashcard.dart'; 
import 'package:bytecards/widgets/flashcard_widget.dart'; 
import 'package:auto_size_text/auto_size_text.dart';

class PracticeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  
  const PracticeScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentIndex = 0; // Track current flashcard index
  bool _showAnswer = false; // Toggle question/answer view
  double _smallestFontSize = 16; // Default max font size 
  final AutoSizeGroup _difficultyTextGroup = AutoSizeGroup(); // ✅ Ensures same font size across buttons

  void _nextFlashcard() {
    setState(() {
      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++; // Move to next card
        _showAnswer = false; // Reset to question
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateFontSizes(context); 

    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Practice Mode")),
        body: const Center(child: Text("No flashcards available!")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Practice Mode")),
      body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlashcardWidget(
            flashcard: widget.flashcards[_currentIndex],
            showAnswer: _showAnswer,
            onTap: () => setState(() {
              _showAnswer = !_showAnswer; // Toggle between question and answer
            }),
          ),
          const SizedBox(height: 30),
          // ✅ Difficulty Rating Buttons
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          _difficultyButton("Easy", Colors.green, Icons.check, () {
          _rateFlashcard(1); // Lower priority, show less often
        }),
        const SizedBox(width: 15),
          _difficultyButton("Medium", Colors.yellow[700]!, Icons.sentiment_neutral, () {
          _rateFlashcard(2); // Normal interval
        }),
        const SizedBox(width: 15),
         _difficultyButton("Hard", Colors.red, Icons.close, () {
        _rateFlashcard(3); // Higher priority, show more often
      }),
      ],
    ),
        ],
      ),
    ));
  }

  double _calculateFontSize(String text, double maxWidth, double maxFontSize) {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr, 
    ); 

    double fontSize = maxFontSize; 

    while (fontSize > 12) {
      textPainter.text = TextSpan(
        text: text, 
        style: TextStyle(fontSize: fontSize), 
      );
      textPainter.layout(); 
      if (textPainter.width <= maxWidth) {
        return fontSize; 
      }
      fontSize -= 0.5; 
    }
    return fontSize; 
  }
  
  void _updateFontSizes(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width / 3 - 20; 

    setState(() {
      _smallestFontSize = [
        _calculateFontSize("Easy", maxWidth, 16),
        _calculateFontSize("Medium", maxWidth, 16), 
        _calculateFontSize("Hard", maxWidth, 16), 
      ].reduce((a,b) => a < b ? a : b); 
    }
    );
  }

  Widget _difficultyButton(String label, Color color, IconData icon, VoidCallback onPressed) {
  return SizedBox(
    height: 50, 
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: FittedBox(
        fit: BoxFit.scaleDown, 
        child: AutoSizeText(
          label, 
          maxLines: 1, 
          style: TextStyle(
            fontSize: _smallestFontSize, 
            color: Colors.white
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Sets button color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),);
}

void _rateFlashcard(int difficulty) {
  // Store rating (you can save this in a database for future review)
  print("Rated Flashcard as Difficulty Level: $difficulty");

  setState(() {
    if (_currentIndex < widget.flashcards.length - 1) {
      _currentIndex++; // Move to the next card
      _showAnswer = false; // Reset to question side
    } else {
      // End of flashcards
      _showCompletionDialog();
    }
  });
}

// Show completion message when all cards are done
void _showCompletionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Well Done!"),
      content: const Text("You've reviewed all flashcards in this deck."),
      actions: [
        TextButton(
          onPressed: () { 
            Navigator.pop(context); // pop once to close the completion dialog 
            Navigator.pop(context); // pop once more to go back to flashcard details screen
            Navigator.pop(context); // pop once more to go back to Home Page
          }, 
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

}

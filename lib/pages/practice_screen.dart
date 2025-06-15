import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bytecards/datamodels/flashcard.dart';
import 'package:bytecards/widgets/flashcard_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PracticeScreen extends StatefulWidget {
  // Pass the name of the selected deck
  final String deckTitle;

  // Pass the flashcards of the selected deck
  final List<Flashcard> flashcards;

  // Constructor of a PracticeScreen obj
  const PracticeScreen({
    Key? key,
    required this.flashcards,
    required this.deckTitle,
  }) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentIndex = 0; // Track current flashcard index
  bool _showAnswer = false; // Toggle question/answer view
  double _smallestFontSize = 16; // Default max font size

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcards[_currentIndex];
    final totalCards = widget.flashcards.length;
    final progress = (_currentIndex + 1) / totalCards;

    return Scaffold(
      backgroundColor: const Color(0xFF4A45C4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📘 Top Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.deckTitle,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 📄 Flashcard Display
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: _showAnswer ? 1 : 0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    // Flip direction and content
                    final isFront = value < 0.5;
                    final displayText =
                        isFront ? flashcard.question : flashcard.answer;

                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(value * 3.14), // flip 180 degrees
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()..rotateY(
                                value > 0.5 ? 3.14 : 0,
                              ), // flip the text back when the card has been flipped
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                displayText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 📊 Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentIndex + 1}/$totalCards',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ➡️ Next Card Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _difficultyButton(
                      "Easy",
                      Colors.green,
                      Icons.sentiment_satisfied_alt,
                      () => _rateFlashcard(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _difficultyButton(
                      "Medium",
                      Colors.orange,
                      Icons.sentiment_neutral,
                      () => _rateFlashcard(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _difficultyButton(
                      "Hard",
                      Colors.red,
                      Icons.sentiment_dissatisfied,
                      () => _rateFlashcard(3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      ].reduce((a, b) => a < b ? a : b);
    });
  }

  Widget _difficultyButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
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
            style: TextStyle(fontSize: _smallestFontSize, color: Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Sets button color
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _rateFlashcard(int difficulty) async {
    final card = widget.flashcards[_currentIndex];

    // 🔥 Here’s the magic: card.id must be non-null
    if (card.id != null) {
      await DatabaseHelper.instance.insertReview(
        card.id!,
        DateTime.now(),
        difficulty,
      );
    }

    setState(() {
      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++;
        _showAnswer = false;
      } else {
        _showCompletionDialog();
      }
    });
  }

  // Show completion message when all cards are done
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Well Done!"),
            content: const Text("You've reviewed all flashcards in this deck."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); // pop once to close the completion dialog
                  Navigator.pop(
                    context,
                  ); // pop once more to go back to flashcard details screen
                  Navigator.pop(
                    context,
                  ); // pop once more to go back to Home Page
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}

import 'package:flutter/material.dart';
import '../datamodels/flashcard.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onTap;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    required this.showAnswer,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Toggle between question and answer
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          showAnswer ? flashcard.answer : flashcard.question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

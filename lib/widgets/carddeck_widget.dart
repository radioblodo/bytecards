import 'package:flutter/material.dart';

import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';

class CardDeckWidget extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CardDeckWidget({
    Key? key,
    required this.deck,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, //Navigate to the deck screen when clicked
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(deck.color),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deck.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${deck.flashcards.length} " +
                  AppLocalizations.of(context)!.flashcards,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

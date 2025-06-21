import 'dart:convert';
import 'dart:io';

import 'package:bytecards/datamodels/flashcard.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';
import 'package:bytecards/pages/add_flashcard_screen.dart';
import 'package:bytecards/pages/practice_screen.dart';
import 'package:bytecards/services/storage_service.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:read_pdf_text/read_pdf_text.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;
  const DeckDetailScreen({Key? key, required this.deck}) : super(key: key);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  List<Flashcard> _generatedFlashcards = [];
  bool _isGenerating = false;

  /// 1) Open file picker
  void _pickDocument() async {
    final apiKey = await StorageService.loadApiKey();
    final loc = AppLocalizations.of(context)!;

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.pleaseEnterAPIKey)));
      return; // 🛑 stop before file picker
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx'],
    );
    final path = result?.files.single.path;
    if (path != null) {
      _generateFlashcardsFromAI(path, apiKey);
    }
  }

  // Helper method to preprocess parsed text from read_pdf_text
  String _preprocessText(String input) {
    return input
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Collapse all whitespace to single space
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove double line breaks
        .replaceAll(
          RegExp(r'[^\x00-\x7F]'),
          '',
        ) // Optional: Remove non-ASCII chars
        .trim();
  }

  /// 2) Extract text, call AI, parse JSON
  Future<void> _generateFlashcardsFromAI(String filePath, String apiKey) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isGenerating = true);

    String text;
    final ext = filePath.split('.').last.toLowerCase();

    // ── STEP 1: Extract text ───────────────────────────
    try {
      if (ext == 'pdf') {
        final rawText = await ReadPdfText.getPDFtext(filePath);
        if (rawText.trim().isEmpty) {
          throw Exception("PDF appears to be scanned or empty.");
        }
        text = _preprocessText(rawText);
      } else if (ext == 'txt') {
        text = await File(filePath).readAsString(encoding: utf8);
      } else {
        throw FormatException('Unsupported extension: .$ext');
      }
    } catch (e, st) {
      debugPrint('Text extraction error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.fileReadError)));
      setState(() => _isGenerating = false);
      return;
    }

    // ── STEP 2–4: Chunking + AI Calls + Parsing ───────────────
    List<Flashcard> allCards = [];

    const chunkSize = 2000;
    final chunks = <String>[];
    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(
        text.substring(
          i,
          i + chunkSize > text.length ? text.length : i + chunkSize,
        ),
      );
    }

    for (final chunk in chunks) {
      final chunkCards = await _generateCardsFromChunk(chunk, apiKey);
      allCards.addAll(chunkCards);
      if (allCards.length >= 5) break;
    }

    // ── STEP 5: Show results ────────────────────────────
    setState(() => _generatedFlashcards = allCards.take(5).toList());
    if (_generatedFlashcards.isNotEmpty) {
      _showGeneratedCardsDialog();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.malformedResponse)));
    }

    setState(() => _isGenerating = false);
  }

  Future<List<Flashcard>> _generateCardsFromChunk(
    String chunk,
    String apiKey,
  ) async {
    final localeCode = Localizations.localeOf(context).languageCode;
    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'openai/gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an AI that creates Anki-style flashcards in Q&A format.',
            },
            {
              'role': 'user',
              'content': '''
                  Generate 3 flashcards as JSON [{"question":"...","answer":"..."}] from the text below.
                  The question of the flashcards must be written in ${localeCode == 'zh' ? 'Chinese' : 'English'}.

                  Text:
                  $chunk
                  ''',
            },
          ],
        }),
      );

      if (response.statusCode != 200) return [];

      final rawBody = utf8.decode(response.bodyBytes); // Fix encoding
      final raw =
          jsonDecode(rawBody)['choices'][0]['message']['content']
              .replaceAll(RegExp(r'^```(?:json)?'), '')
              .replaceAll(RegExp(r'```$'), '')
              .trim();

      final regex = RegExp(r'\{[^{}]+\}', multiLine: true);
      final matches = regex.allMatches(raw);
      return matches.map((match) {
        final map = jsonDecode(match.group(0)!);
        return Flashcard(
          question: map['question'] ?? '',
          answer: map['answer'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// 3) Confirm & save to DB
  Future<void> _confirmGeneratedCards() async {
    for (var card in _generatedFlashcards) {
      await DatabaseHelper.instance.insertFlashcard(card, widget.deck.deckId);
    }
    setState(() => _generatedFlashcards.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.cardsAdded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.title)),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Practice button ─────────────────────────────
              _actionButton(loc.practiceNow, Icons.play_arrow, () async {
                final cards = await DatabaseHelper.instance.getFlashcards(
                  widget.deck.deckId,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PracticeScreen(
                          flashcards: cards,
                          deckTitle: widget.deck.title,
                        ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ── Manual vs. AI row ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    loc.manuallyAddCards,
                    Icons.edit,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                AddFlashcardScreen(deckId: widget.deck.deckId),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _actionButton(
                    loc.generateFromAI,
                    Icons.auto_awesome,
                    _pickDocument,
                  ),
                ],
              ),

              // ── Loading indicator ───────────────────────────
              if (_isGenerating) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],

              // ── Preview & confirm ───────────────────────────
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 140,
      height: 180,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showGeneratedCardsDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false, // force them to Confirm or Cancel
      builder: (context) {
        return AlertDialog(
          title: Text(loc.generatedCards),
          content: SizedBox(
            width: double.maxFinite,
            // constrain height so it scrolls if long
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: _generatedFlashcards.length,
              itemBuilder: (ctx, i) {
                final c = _generatedFlashcards[i];
                return ListTile(
                  title: Text(c.question),
                  subtitle: Text(c.answer),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editFlashcardDialog(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() => _generatedFlashcards.removeAt(i));
                          (context as Element)
                              .markNeedsBuild(); // Refresh dialog
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(loc.cancel),
              onPressed: () {
                setState(() => _generatedFlashcards.clear());
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(loc.confirmAddAll),
              onPressed: () {
                _confirmGeneratedCards();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editFlashcardDialog(int index) {
    final loc = AppLocalizations.of(context)!;
    final card = _generatedFlashcards[index];
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
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _generatedFlashcards[index] = Flashcard(
                      question: questionController.text,
                      answer: answerController.text,
                    );
                  });
                  Navigator.of(context).pop();
                  // Refresh the dialog view
                  (context as Element).markNeedsBuild();
                },
                child: Text(loc.save),
              ),
            ],
          ),
    );
  }
}

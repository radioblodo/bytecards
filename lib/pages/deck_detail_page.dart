import 'dart:convert';
import 'dart:io';

import 'package:bytecards/datamodels/flashcard.dart';
import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';
import 'package:bytecards/pages/add_flashcard_screen.dart';
import 'package:bytecards/pages/practice_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;
  const DeckDetailScreen({Key? key, required this.deck}) : super(key: key);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  List<Flashcard> _generatedFlashcards = [];
  bool _isGenerating = false;

  // 1) Fire file picker
  void _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx'],
    );
    if (result?.files.single.path != null) {
      _generateFlashcardsFromAI(result!.files.single.path!);
    }
  }

  // 2) Extract text, call OpenRouter, parse JSON
  Future<void> _generateFlashcardsFromAI(String filePath) async {
    setState(() => _isGenerating = true);

    // ── 1) extract raw text ───────────────────────────────
    String text;
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      final bytes = await File(filePath).readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      text = PdfTextExtractor(doc).extractText();
      doc.dispose();
    } else if (ext == 'txt') {
      text = await File(filePath).readAsString();
    } else {
      // unsupported
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unsupportedFormat),
        ),
      );
      setState(() => _isGenerating = false);
      return;
    }

    // ── send to AI ────────────────────────────────────────
    const apiKey = 'sk-your-openrouter-key';
    const model = 'mistral';
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an AI that creates Anki-style flashcards in Q&A format.',
          },
          {
            'role': 'user',
            'content':
                'Generate 5 flashcards as JSON [{"question":"...","answer":"..."}] from the text below:\n\n$text',
          },
        ],
      }),
    );

    // ── handle response ───────────────────────────────────
    if (resp.statusCode == 200) {
      try {
        final content =
            jsonDecode(resp.body)['choices'][0]['message']['content'];
        final cards =
            (jsonDecode(content) as List).map((m) {
              return Flashcard(question: m['question'], answer: m['answer']);
            }).toList();

        setState(() {
          _generatedFlashcards = cards;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.parseError)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.apiError(resp.statusCode.toString()),
          ),
        ),
      );
    }

    setState(() => _isGenerating = false);
  }

  // 3) Confirm & insert into DB
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
              _actionButton(loc.practiceNow, Icons.play_arrow, () async {
                final cards = await DatabaseHelper.instance.getFlashcards(
                  widget.deck.deckId,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PracticeScreen(flashcards: cards),
                  ),
                );
              }),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(loc.manuallyAddCards, Icons.edit, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                AddFlashcardScreen(deckId: widget.deck.deckId),
                      ),
                    );
                  }),
                  const SizedBox(width: 20),
                  _actionButton(
                    loc.generateFromAI,
                    Icons.auto_awesome,
                    _pickDocument,
                  ),
                ],
              ),

              if (_isGenerating) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],

              if (_generatedFlashcards.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  loc.generatedCards,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _generatedFlashcards.length,
                    itemBuilder: (ctx, i) {
                      final c = _generatedFlashcards[i];
                      return ListTile(
                        title: Text(c.question),
                        subtitle: Text(c.answer),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              () => setState(
                                () => _generatedFlashcards.removeAt(i),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _confirmGeneratedCards,
                  child: Text(loc.confirmAddAll),
                ),
              ],
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
}

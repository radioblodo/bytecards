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

  /// 1) Open file picker
  void _pickDocument() async {
    final apiKey = await StorageService.loadApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter your API key in Settings."),
        ),
      );
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

  /// 2) Extract text, call AI, parse JSON
  Future<void> _generateFlashcardsFromAI(String filePath, String apiKey) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isGenerating = true);

    String text;
    final ext = filePath.split('.').last.toLowerCase();

    // ──  STEP 1: Extract text ─────────────────────────────────
    try {
      if (ext == 'pdf') {
        print("🛠  Extracting PDF text from $filePath");
        final bytes = await File(filePath).readAsBytes();
        final doc = PdfDocument(inputBytes: bytes);
        text = PdfTextExtractor(doc).extractText();
        doc.dispose();
      } else if (ext == 'txt') {
        print("🛠  Reading TXT from $filePath");
        text = await File(filePath).readAsString();
      } else {
        throw FormatException('Unsupported extension: .$ext');
      }
      print("✅ Extracted text length: ${text.length}");
    } catch (e, st) {
      debugPrint('❌ Text extraction error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.fileReadError)));
      setState(() => _isGenerating = false);
      return;
    }

    // ──  STEP 2: Call AI endpoint ───────────────────────────────
    http.Response resp;
    try {
      print("🛰  Sending to AI…");
      resp = await http.post(
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
              'content':
                  'Generate 5 flashcards as JSON [{"question":"...","answer":"..."}] from the text below:\n\n$text',
            },
          ],
        }),
      );
      print("📬 AI responded: ${resp.statusCode}");
    } catch (e, st) {
      debugPrint('❌ HTTP error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error – please check your connection.'),
        ),
      );
      setState(() => _isGenerating = false);
      return;
    }

    // ──  STEP 3: Handle HTTP status ────────────────────────────
    if (resp.statusCode != 200) {
      debugPrint('❌ AI API returned ${resp.statusCode}: ${resp.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.apiError(resp.statusCode.toString()))),
      );
      setState(() => _isGenerating = false);
      return;
    }

    // ──  STEP 4: Parse JSON ────────────────────────────────────
    try {
      // 1) Pull out the AI’s “message” content
      final raw = jsonDecode(resp.body)['choices'][0]['message']['content'];

      // 2) Log it so you see exactly what came back
      print('🔍 Raw AI content:\n$raw');

      // 3) Strip out any Markdown fences (``` or ```json)
      final cleaned =
          raw
              .replaceAll(RegExp(r'^```(?:json)?'), '') // opening
              .replaceAll(RegExp(r'```$'), '') // closing
              .trim();

      // 4) Now parse the cleaned JSON
      List<Flashcard> cards = [];

      try {
        // Clean markdown fences first
        final cleaned = raw.replaceAll(RegExp(r'```(?:json)?'), '').trim();

        // Extract all JSON-like objects from the cleaned text
        final regex = RegExp(r'\{[^{}]+\}', multiLine: true);
        final matches = regex.allMatches(cleaned);

        for (final match in matches) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            final map = jsonDecode(jsonStr);
            cards.add(
              Flashcard(
                question: map['question'] ?? '',
                answer: map['answer'] ?? '',
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Failed to parse individual JSON objects: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ AI response was incomplete or malformed."),
          ),
        );
      }

      // 5) Update state & show dialog
      setState(() => _generatedFlashcards = cards);
      if (_generatedFlashcards.isNotEmpty) {
        _showGeneratedCardsDialog();
      }

      print("✅ Parsed ${cards.length} flashcards");
    } catch (e, st) {
      debugPrint('❌ JSON parse error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.parseError)));
    }
    setState(() => _isGenerating = false);
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _generatedFlashcards.removeAt(i));
                      // refresh the dialog
                      (context as Element).markNeedsBuild();
                    },
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
}

import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/pages/deck_detail_page.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:bytecards/database/database_helper.dart';
import 'package:bytecards/widgets/create_deck_screen.dart';
import 'package:bytecards/widgets/carddeck_widget.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Deck> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _loadDecks() async {
    final decks = await DatabaseHelper.instance.getDecks();
    setState(() {
      _decks = decks;
    });
  }

  void _navigateToCreateDeck() async {
    _animationController.reverse();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateDeckScreen()),
    );
    _loadDecks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _animationController.reverse(),
      child: Scaffold(
        appBar: AppBar(title: Text(loc.homeTitle)),
        body:
            _decks.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      loc.noDecksMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: _decks.length,
                  itemBuilder: (context, index) {
                    return CardDeckWidget(
                      deck: _decks[index],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DeckDetailScreen(deck: _decks[index]),
                          ),
                        );
                        _loadDecks();
                        print("Tapped on ${_decks[index].title}");
                      },
                      onLongPress: () {
                        _showDeckOptionsDialog(context, _decks[index]);
                      },
                    );
                  },
                ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 76.0),
          child: FloatingActionBubble(
            animation: _animation,
            onPress: () {
              _animationController.isCompleted
                  ? _animationController.reverse()
                  : _animationController.forward();
            },
            iconColor: Colors.white,
            iconData: Icons.add,
            backGroundColor: const Color(0xFF4A45C4),
            items: [
              Bubble(
                title: loc.createDeck,
                bubbleColor: const Color(0xFF4A45C4),
                icon: Icons.library_add,
                iconColor: Colors.white,
                titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  _navigateToCreateDeck();
                  _animationController.reverse();
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void _showDeckOptionsDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Options for ${deck.title}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Deck"),
                  onTap: () {
                    Navigator.pop(context);
                    _editDeck(deck);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Delete Deck"),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteDeck(deck);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text("Choose a color"),
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPickerDialog(context, deck);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _editDeck(Deck deck) {
    print("Editing ${deck.title}");
    // TODO: Implement navigation to edit screen
  }

  void _deleteDeck(Deck deck) async {
    await DatabaseHelper.instance.deleteDeck(deck.deckId);
    setState(() {
      _decks.remove(deck);
    });
    print("Deleted ${deck.title}");
  }

  void _showColorPickerDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Deck Color"),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorOption(context, deck, Colors.red),
                _colorOption(context, deck, Colors.green),
                _colorOption(context, deck, Colors.blue),
                _colorOption(context, deck, Colors.yellow),
                _colorOption(context, deck, Colors.purple),
                _colorOption(context, deck, Colors.orange),
                _colorOption(context, deck, Colors.cyan),
                _colorOption(context, deck, Colors.pink),
                _colorOption(context, deck, Colors.teal),
                _customColorOption(context, deck),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorOption(BuildContext context, Deck deck, Color color) {
    return GestureDetector(
      onTap: () async {
        await DatabaseHelper.instance.updateDeckColor(deck.deckId, color.value);
        setState(() {
          deck.color = color.value;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }

  Widget _customColorOption(BuildContext context, Deck deck) {
    return GestureDetector(
      onTap: () => _showFullColorPicker(context, deck),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  void _showFullColorPicker(BuildContext context, Deck deck) {
    Color selectedColor = Color(deck.color);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a Custom Color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => selectedColor = color,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Select"),
              onPressed: () async {
                await DatabaseHelper.instance.updateDeckColor(
                  deck.deckId,
                  selectedColor.value,
                );
                setState(() {
                  deck.color = selectedColor.value;
                });
                Navigator.pop(context); // Close picker
                Navigator.pop(context); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}

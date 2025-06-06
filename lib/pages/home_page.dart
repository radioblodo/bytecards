import 'package:bytecards/datamodels/deck.dart';
import 'package:bytecards/pages/deck_detail_page.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:bytecards/database/database_helper.dart'; 
import 'package:bytecards/widgets/create_deck_screen.dart'; 
import 'package:bytecards/widgets/carddeck_widget.dart'; 
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; 

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation; 

  List<Deck> _decks = []; 
  
  @override
  void initState() {
    super.initState(); 
    _loadDecks(); 

    //Initialize animation controller
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
    List<Deck> decks = await DatabaseHelper.instance.getDecks();
    setState(() {
      _decks = decks; 
    }); 
  }

  void _navigateToCreateDeck() async {
    _animationController.reverse(); 
    //Navigate to create deck screen and wait for result 
    await Navigator.push( 
      context, 
      MaterialPageRoute(builder: (context) => CreateDeckScreen()), 
    );
    //Refresh deck list after returning 
    _loadDecks(); 
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector( 
      onTap: () {
        _animationController.reverse(); 
      }, 
      child: Scaffold(
        appBar: AppBar(title: Text('ByteCards Home')),
        body: _decks.isEmpty ? const Center(child: Text("You have no decks yet. Tap + to create one.")) :
        ListView.builder(
          itemCount: _decks.length, 
          itemBuilder: (context, index) {
            return CardDeckWidget(
              deck: _decks[index], 
              onTap: () { 
                // Navigate to deck details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeckDetailScreen(deck: _decks[index]),
                      ),
                    );
                print("Tapped on ${_decks[index].title}");
              },
              onLongPress: () {
                _showDeckOptionsDialog(context, _decks[index]); // ✅ Show options on long press
              }
            );
          }
        ),
        floatingActionButton: FloatingActionBubble(
          animation: _animation, 
          onPress: () {
             _animationController.isCompleted
                ? _animationController.reverse()
                : _animationController.forward();
          },
          iconColor: Colors.white, 
          iconData: Icons.add, 
          backGroundColor: Colors.blue,
          items: <Bubble> [
            //Floating action menu item
            Bubble(
              title: "Create a new deck          ",
              bubbleColor: Colors.blue,
              iconColor: Colors.transparent,
              icon: Icons.circle, 
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress:(){
                 _navigateToCreateDeck();
                _animationController.reverse();
              },
            ),
          ]
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      )
    );
  }

  void _showDeckOptionsDialog(BuildContext context, Deck deck) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
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
            leading: const Icon(Icons.edit),
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

//To be implemented 05-03-2025
void _editDeck(Deck deck) {
  print("Editing ${deck.title}");
  // TODO: Navigate to edit screen
}

void _deleteDeck(Deck deck) async{
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
              // "+" button for custom color picker
              _customColorOption(context, deck), 
            ],
          ),
        ), 
      );
    },
  );
}

// ✅ Build Color Option
Widget _colorOption(BuildContext context, Deck deck, Color color) {
  return GestureDetector(
    onTap: () async {
      await DatabaseHelper.instance.updateDeckColor(deck.deckId, color.value); // ✅ Update DB
      setState(() {
        deck.color = color.value; // ✅ Update UI
      });
      Navigator.pop(context); // Close Dialog
    },
    child: Container(
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
    onTap: () {
      _showFullColorPicker(context, deck);
    },

    child: Container(
      width: 40, 
      height: 40, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1), 
      ),
      child: const Icon(Icons.add, size: 24), // "+" icon inside a circle
    ),
  );
}

void _showFullColorPicker(BuildContext context, Deck deck) {
  Color selectedColor = Color(deck.color); // Get the current deck color 

  showDialog(
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text("Pick a Custom Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color; 
            },
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
              await DatabaseHelper.instance.updateDeckColor(deck.deckId, selectedColor.value);
              setState(() {
                deck.color = selectedColor.value; 
              });
              Navigator.pop(context); // close picker 
              Navigator.pop(context); // close color selection dialog 
            }
          )
        ]
      );
    }
  );
}

}


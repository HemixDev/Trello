import 'package:flutter/material.dart';
import 'package:task_box_work/card_zoom.dart';
import 'package:task_box_work/fetch.dart';
import 'package:task_box_work/board.dart';

class BoardCard extends StatefulWidget {
  final String listId;

  BoardCard({required this.listId});

  @override
  _CardState createState() => _CardState();
}

class _CardState extends State<BoardCard> {
  late Future<List<dynamic>> _cardsFuture;

  // Method to navigate to BoardCardsPage
  void initState() {
    super.initState();
    _cardsFuture = fetchCards(widget.listId);
  }

  // Function to edit a board
  Future<void> editBoard(String boardId, String currentName) async {
    // Implement your edit board logic here
  }

  // Function to delete a board
  Future<void> deleteBoard(String boardId) async {
    // Implement your delete board logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartes du Tableau'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> cards = snapshot.data!;
            return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cards[index]['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetails(
                          cardId: cards[index]['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

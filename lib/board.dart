import 'package:flutter/material.dart';
import 'package:task_box_work/fetch.dart';
import 'package:task_box_work/board_card.dart';
import 'package:task_box_work/board_lists.dart';
import 'package:http/http.dart' as http;

class Boards extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Boards> {
  late Future<List<dynamic>> _boardsFuture;

  @override
  void initState() {
    super.initState();
    _boardsFuture = fetchBoards();
  }

  // Method to navigate to BoardCardPage
  void _viewBoard(String boardId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardLists(boardId: boardId),
      ),
    );
  }

  // Function to edit a board
  Future<void> editBoard(String boardId, String currentName) async {
    String? newName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller =
            TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('Modifier le nom du tableau'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Nouveau nom'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text.trim());
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      final response = await http.put(
        Uri.https('api.trello.com', '/1/boards/$boardId', {
          'key': 'ff244c6588d8673d3cebb9cb5313e263',
          'token':
              //'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
          'name': newName,
        }),
      );

      if (response.statusCode == 200) {
        // Board updated successfully
        setState(() {
          // Refresh the UI, maybe by refetching the boards list
          _boardsFuture = fetchBoards();
        });
      } else {
        throw Exception('Failed to update board');
      }
    }
  }

  // Function to delete a board
  Future<void> deleteBoard(String boardId) async {
    final response = await http.delete(
      Uri.https('api.trello.com', '/1/boards/$boardId', {
        'key': 'ff244c6588d8673d3cebb9cb5313e263',
        'token':
            //'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
      }),
    );

    if (response.statusCode == 200) {
      // Board deleted successfully, you may want to refresh the boards list
      setState(() {
        // Refresh the UI, maybe by refetching the boards list
        _boardsFuture = fetchBoards();
      });
    } else {
      throw Exception('Failed to delete board');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: FutureBuilder<List<dynamic>>(
        future: fetchBoards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> boards = snapshot.data!;
            return GridView.count(
              crossAxisCount: 1,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              padding: EdgeInsets.all(10.0),
              children: boards.map((board) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to BoardCardPage when a board is tapped
                    _viewBoard(board['id']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(board['backgroundUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            board['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.black,
                                onPressed: () {
                                  deleteBoard(board['id']);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.black,
                                onPressed: () {
                                  editBoard(board['id'], board['name']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:task_box_work/board_card.dart';
import 'package:task_box_work/fetch.dart';
import 'package:http/http.dart' as http;

class BoardLists extends StatefulWidget {
  final String boardId;
  BoardLists({required this.boardId});

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<BoardLists> {
  late Future<List<dynamic>> _listsFuture;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listsFuture = fetchLists(widget.boardId);
  }

  void _viewBoardCards(String listId) {
    Navigator.push(
      context,
       MaterialPageRoute(
        builder: (context) => BoardCard(listId: listId),
        )
      );
  }

  Future<void> editList(String listId, String currentName) async {
    String? newName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller =
            TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('Modifier le nom de la liste'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Choisissez un nouveau nom'),
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
        Uri.https('api.trello.com', '/1/lists/$listId', {
          'key': 'ff244c6588d8673d3cebb9cb5313e263',
          'token':
              //'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
          'name': newName,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _listsFuture = fetchLists(widget.boardId);
        });
      } else {
        throw Exception('Failed to update list');
      }
    }
  }

  Future<void> deleteList(String listId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer cette liste ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                print('non supprimé');
              },
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                print('supprimé');
              },
              child: Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final response = await http.put(
        Uri.https('api.trello.com', '/1/lists/$listId/closed?', {
          'key': 'ff244c6588d8673d3cebb9cb5313e263',
          'token':
              //'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _listsFuture = fetchLists(widget.boardId);
        });
      } else {
        throw Exception('Échec de la suppression de la liste');
      }
    }
  }

  Future<void> createList(String listName) async {
    try {
      final response = await http.post(
        Uri.https('api.trello.com', '/1/lists', {
          'key': 'ff244c6588d8673d3cebb9cb5313e263',
          'token':
              //'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
          'name': listName,
          'idBoard': widget.boardId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _listsFuture = fetchLists(widget.boardId);
        });
      } else {
        throw Exception('Failed to create list');
      }
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listes du Board'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> cards = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      Color color =
                          index % 2 == 0 ? Colors.blue[100]! : Colors.blue[200]!;
                      return Container(
                        color: color,
                        child: ListTile(
                          title: Text(cards[index]['name']),
                          onTap: () {
                            _viewBoardCards(cards[index]['id']);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  editList(
                                      cards[index]['id'], cards[index]['name']);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteList(cards[index]['id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ajouter une nouvelle liste'),
                          content: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Nom de la nouvelle liste',
                            ),
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
                                createList(_nameController.text.trim());
                                Navigator.of(context).pop();
                              },
                              child: Text('Ajouter'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

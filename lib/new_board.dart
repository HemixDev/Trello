import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:task_box_work/fetch.dart';


class NewBoard extends StatefulWidget {
  @override
  _NewBoardState createState() => _NewBoardState();
}

class _NewBoardState extends State<NewBoard> {
  bool isPrivate = true; // Initial value for private workspace
  bool isWorkspace = false; // Initial value for workspace
  bool isPublic = false; // Initial value for public workspace
  Future<List<dynamic>> _boardsFuture = fetchBoards();

  final TextEditingController _projectNameController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  void _showConfirmationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('le tableau a été crée !'),
      ),
    );
  }

  Future<void> createBoard(String boardName, {String? visibility}) async {
    try {
      final response = await http.post(
        Uri.https('api.trello.com', '/1/boards', {
          'key': 'ff244c6588d8673d3cebb9cb5313e263',
          'token':
              'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
          'name': boardName,
          if (visibility != null) 'prefs_permissionLevel': visibility,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Board created successfully
        setState(() {
          // Refresh the UI, maybe by refetching the boards list
          _boardsFuture = fetchBoards();
        });
        _showConfirmationSnackBar(); // Afficher le SnackBar de confirmation
      } else {
        throw Exception('Failed to create board: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating board: $e');
      throw Exception('Failed to create board: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer un nouveau projet Trello ici',
          style: TextStyle(fontSize: 24.0, color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.lightBlueAccent,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _projectNameController,
              maxLength: 15, // Limite de 15 caractères
              decoration: InputDecoration(
                labelText: 'Nom du projet (max. 15 caractères)',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 5.0,
            ), // Espace entre le champ Nom du projet et les cases à cocher
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espace de travail:',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                CheckboxListTile(
                  title: Text('Privée', style: TextStyle(color: Colors.white)),
                  value: isPrivate,
                  onChanged: (newValue) {
                    setState(() {
                      isPrivate = newValue ?? false;
                      if (isPrivate) {
                        isWorkspace = false;
                        isPublic = false;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                ),
                CheckboxListTile(
                  title: Text('Espace de travail',
                      style: TextStyle(color: Colors.white)),
                  value: isWorkspace,
                  onChanged: (newValue) {
                    setState(() {
                      isWorkspace = newValue ?? false;
                      if (isWorkspace) {
                        isPrivate = false;
                        isPublic = false;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                ),
                CheckboxListTile(
                  title:
                      Text('Publique', style: TextStyle(color: Colors.white)),
                  value: isPublic,
                  onChanged: (newValue) {
                    setState(() {
                      isPublic = newValue ?? false;
                      if (isPublic) {
                        isPrivate = false;
                        isWorkspace = false;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                ),
              ],
            ),
            SizedBox(
                height:
                    0), // Espace entre les cases à cocher et le bouton Créer
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici la logique pour créer le projet en fonction des options sélectionnées
                // Peut-être une fonction qui utilise les valeurs de isPrivate, isWorkspace, isPublic et le nom du projet
                String projectName = _projectNameController.text;
                // Vérifiez si le nom du projet dépasse la limite de 15 caractères
                if (projectName.length > 15) {
                  // Si le nom du projet dépasse la limite, tronquez-le à 15 caractères
                  projectName = projectName.substring(0, 15);
                }
                // Utilisez projectName pour créer le projet
                createBoard(projectName,
                    visibility: isPrivate
                        ? 'private'
                        : isWorkspace
                            ? 'workspace'
                            : 'public');
              },
              child: Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
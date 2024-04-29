import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardDetails extends StatefulWidget {
  final String cardId;

  CardDetails({required this.cardId});

  @override
  _CardDetailsState createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late Future<Map<String, dynamic>> _cardDetailsFuture;

  @override
  void initState() {
    super.initState();
    _cardDetailsFuture = fetchCardDetails(widget.cardId);
  }

  Future<Map<String, dynamic>> fetchCardDetails(String cardId) async {
    final response = await http.get(
      Uri.https('api.trello.com', '/1/cards/$cardId', {
        'key': 'ff244c6588d8673d3cebb9cb5313e263',
        'token':
            'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> cardDetails = jsonDecode(response.body);
      List<dynamic> checklists = await fetchChecklists(cardId);
      cardDetails['checklists'] = checklists;
      return cardDetails;
    } else {
      throw Exception('Failed to load card details');
    }
  }

  Future<List<dynamic>> fetchChecklists(String cardId) async {
    final response = await http.get(
      Uri.https('api.trello.com', '/1/cards/$cardId/checklists', {
        'key': 'ff244c6588d8673d3cebb9cb5313e263',
        'token':
            'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> checklists = jsonDecode(response.body);
      return checklists;
    } else {
      throw Exception('Failed to load checklists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la carte'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _cardDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> cardDetails = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Name: ${cardDetails['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Description: ${cardDetails['desc'] ?? 'No description'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Checklists:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cardDetails['checklists'].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(cardDetails['checklists'][index]['name']),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

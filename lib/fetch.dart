import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = FlutterSecureStorage();
const String _tokenKey = 'trello_token';
String? _token;

Future<void> _getToken() async {
  _token = await _secureStorage.read(key: _tokenKey);
  print('token: $_token');
}

Future<List<dynamic>> fetchBoards() async {
  await _getToken();
  final response = await http.get(
    Uri.https('api.trello.com', '/1/members/me/boards', {
      'key': 'ff244c6588d8673d3cebb9cb5313e263',
      'token':
          'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
    }),
  );

  if (response.statusCode == 200) {
    List<dynamic> boards = jsonDecode(response.body);
    return boards.map((board) {
      // Vérifiez si 'prefs' et 'backgroundImageScaled' existent avant d'y accéder
      var backgroundImageScaled = board['prefs'] != null
          ? board['prefs']['backgroundImageScaled']
          : null;
      // Si 'backgroundImageScaled' est null ou vide, utilisez une URL d'image par défaut ou laissez-la vide selon vos besoins
      var backgroundUrl =
          backgroundImageScaled != null && backgroundImageScaled.isNotEmpty
              ? backgroundImageScaled[0]['url']
              : 'URL_PAR_DEFAUT_SI_VIDE';
      board['backgroundUrl'] = backgroundUrl;
      return board;
    }).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}

Future<List<dynamic>> fetchLists(String boardId) async {
  final response = await http.get(
    Uri.https('api.trello.com', '/1/boards/$boardId/lists/', {
      'key': 'ff244c6588d8673d3cebb9cb5313e263',
      'token':
          'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
    }),
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    List<dynamic> lists = jsonDecode(response.body);
    return lists.map((list) {
      var backgroundImageScaled =
          list['prefs'] != null ? list['prefs']['backgroundImageScaled'] : null;
      var backgroundUrl =
          backgroundImageScaled != null && backgroundImageScaled.isNotEmpty
              ? backgroundImageScaled[0]['url']
              : 'URL_PAR_DEFAUT_SI_VIDE';
      list['backgroundUrl'] = backgroundUrl;
      return list;
    }).toList();
  } else {
    throw Exception('Failed to load lists');
  }
}

Future<List<dynamic>> fetchCards(String listId) async {
  final response = await http.get(
    Uri.https('api.trello.com', '/1/lists/$listId/cards', {
      'key': 'ff244c6588d8673d3cebb9cb5313e263',
      'token':
          'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
    }),
  );

  if (response.statusCode == 200) {
    List<dynamic> cards = jsonDecode(response.body);
    return cards.map((card) {
      var title = card['name'];
      print(title);
      return card;
    }).toList();
  } else {
    throw Exception('Failed to load cards');
  }
}

Future<List<dynamic>> fetchCard(String cardId) async {
  final response = await http.get(
    Uri.https('api.trello.com', '/1/cards/$cardId', {
      'key': 'ff244c6588d8673d3cebb9cb5313e263',
      'token':
          'ATTAa496db91d75fc1d4c05cf5765a63941c58ea4548c194cdce60fccb536f9d1c76EF298BFA',
    }),
  );

  if (response.statusCode == 200) {
    List<dynamic> card = jsonDecode(response.body);
    return card;
  } else {
    throw Exception('Failed to load card');
  }
}

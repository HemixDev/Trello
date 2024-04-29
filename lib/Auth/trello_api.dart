import 'package:dio/dio.dart';

class TrelloApi {
  static const String baseUrl = 'https://api.trello.com/1';

  static Future<String> extractUsername(String token) async {
    try {
      Response response = await Dio().get(
        '$baseUrl/members/me',
        queryParameters: {'token': token, 'key': 'a9e4e8c47d2e471c5f173db42325550c'},
      );

      if (response.statusCode == 200) {
        String username = response.data['username'];
        return username;
      } else {
        print('Failed to fetch user information: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error fetching user information: $e');
      return '';
    }
  }
}
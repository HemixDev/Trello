// ignore_for_file: prefer_const_constructors, avoid_print, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_declarations, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:task_box_work/home.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TrelloLoginPage extends StatefulWidget {
  const TrelloLoginPage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<TrelloLoginPage> {
  StreamSubscription? _sub;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinkListener() async {
    // Deep link listener initialization
    _sub = uriLinkStream.listen((Uri? uri) {
      // Handle the deep link
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (Object err) {
      // Handle errors
    });
  }

  void _handleDeepLink(Uri uri) {
    final String tokenKey = 'token=';
    if (uri.fragment != null && uri.fragment.contains(tokenKey)) {
      final tokenIndex = uri.fragment.indexOf(tokenKey) + tokenKey.length;
      final token = uri.fragment.substring(tokenIndex);
      if (token.isNotEmpty) {
        _storeTokenAndNavigate(token);
      }
    }
  }

  Future<void> _storeTokenAndNavigate(String token) async {
    await _secureStorage.write(key: 'trello_token', value: token);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
            title: 'TrelloWish'),
      ),
    );
  }

  Future<void> _authenticateWithTrello() async {
    const String apiKey = 'a9e4e8c47d2e471c5f173db42325550c';
    const String callbackUrl = 'myapp://callback';
    const String appName = 'myapp';

    String authUrl =
        'https://trello.com/1/authorize?expiration=never&name=$appName&scope=read,write&response_type=token&key=$apiKey&return_url=$callbackUrl';

    await _launchUrl(authUrl);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launch(url)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: SizedBox(
            width: 300,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
              child: Text(
                'Bienvenue sur TrelloWish',
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          toolbarHeight: 200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(60),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 87, 173, 231),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _authenticateWithTrello();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(320, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        "CONNEXION",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

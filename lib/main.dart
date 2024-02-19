import 'package:euterpefy/utils/color.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'models/user.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'spotifyToken');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appContext = AppContext();
        if (token != null) {
          _initContext(appContext, token!);
        }
        return appContext;
      },
      child: MaterialApp(
        title: 'Euterpefy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: blue),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'Music Recommender'),
      ),
    );
  }

  Future<void> _initContext(AppContext appContext, String token) async {
    appContext.setToken(token);
    // Optionally initialize SpotifyService here if needed for initial data fetch
    // Fetch user profile
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      appContext.setUser(User.fromJson(data));
    }
  }
}

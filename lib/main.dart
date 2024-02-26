import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/services/auth/refresh_token.dart';
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
  String? refreshToken = await storage.read(key: 'refreshToken');

  runApp(MyApp(refreshToken: refreshToken));
}

class MyApp extends StatelessWidget {
  final String? refreshToken;
  const MyApp({super.key, this.refreshToken});

  @override
  Widget build(BuildContext context) {
    ThemeData lightTheme() {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 211, 226, 255),
        ),
      );
    }

    ThemeData darkTheme() {
      return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff293241),
            brightness: Brightness.dark,
          ));
    }

    return ChangeNotifierProvider(
      create: (context) {
        final appContext = AppContext();
        if (refreshToken != null) {
          _initContext(appContext, refreshToken!);
        }
        return appContext;
      },
      child: Consumer<AppContext>(
          child: const HomePage(title: 'Music Recommender'),
          builder: (c, appContext, child) {
            return MaterialApp(
              title: 'Euterpefy',
              theme: lightTheme(), // Use the light theme
              darkTheme: darkTheme(), // Use the dark theme
              themeMode: appContext.selectedThemeMode, // Use system theme mode
              home: child,
            );
          }),
    );
  }

  Future<void> _initContext(AppContext appContext, String refreshToken) async {
    // get new access token, refreshToken and expiration date
    final tokens = await refreshAccessToken(refreshToken);
    if (tokens == null) {
      return;
    }
    String newAccessToken = tokens['accessToken'];
    String newRefreshToken = tokens['refreshToken'];
    DateTime newExpriationDate = DateTime.parse(tokens['expirationDate']);
    // Optionally initialize SpotifyService here if needed for initial data fetch
    // Fetch user profile
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $newAccessToken'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      appContext.login(User.fromJson(data), newAccessToken, newRefreshToken,
          newExpriationDate);
    }

    // load theme mode
    const storage = FlutterSecureStorage();
    String themeMode = await storage.read(key: 'themeMode') ?? 'system';
    if (appContext.user != null) {
      themeMode = await storage.read(key: '${appContext.user!.id}/themeMode') ??
          themeMode;
    }
    appContext.setTheme(themeMode);
  }
}

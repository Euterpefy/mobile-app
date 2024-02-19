// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/models/user.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:euterpefy/widgets/show_snack_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

Future<String?> getTokenOrLogin(BuildContext context) async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'spotifyToken');
  if (token == null) {
    try {
      token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
        redirectUrl: dotenv.env['REDIRECT_URL']!,
        scope:
            "user-top-read,user-read-email,user-read-private,playlist-modify-public,playlist-modify-private,playlist-read-private,playlist-read-collaborative",
      );
      await storage.write(key: 'spotifyToken', value: token);
      showSnackBar(context, 'Logged in successfully');
    } catch (e) {
      showSnackBar(context, 'Login failed or was cancelled');
      return null;
    }
  }

  if (Provider.of<AppContext>(context, listen: false).user == null) {
    User? user = await _fetchUserProfile(token);
    if (user != null) {
      Provider.of<AppContext>(context, listen: false).login(user, token);
    } else {
      Provider.of<AppContext>(context, listen: false).logout();
    }
  }
  return token;
}

Future<String?> checkToken(BuildContext context) async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'spotifyToken');
  if (token == null) {
    Provider.of<AppContext>(context, listen: false).logout();
  }
  return token;
}

Future<User?> _fetchUserProfile(String token) async {
  var response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    // Create a User object from the data
    var user = User.fromJson(data);
    // Update global user state

    return user;
  }

  return null;
}

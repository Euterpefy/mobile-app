// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:euterpefy/models/user.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/services/auth/token_exchange.dart';
import 'package:euterpefy/widgets/login/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

String _generateCodeVerifier() {
  final Random random = Random.secure();
  final List<int> values = List<int>.generate(64, (i) => random.nextInt(256));
  return base64Url.encode(values).replaceAll('=', '');
}

Future<String> _generateCodeChallenge(String verifier) async {
  List<int> bytes = utf8.encode(verifier);
  Digest digest = sha256.convert(bytes);
  return base64Url.encode(digest.bytes).replaceAll('=', '');
}

Future<void> _storeCodeVerifier(String verifier) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'codeVerifier', value: verifier);
}

Future<String?> getCodeVerifier() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'codeVerifier');
}

Future<void> storeSpotifyOAuthCode(String code) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'spotifyOAuthCode', value: code);
}

Future<String?> getSpotifyOAuthCode() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'spotifyOAuthCode');
}

Future<void> initiateSpotifyLogin(BuildContext context) async {
  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
  final String redirectUri = dotenv.env['REDIRECT_URI']!;
  const String scope =
      "user-top-read,user-read-email,user-read-private,playlist-modify-public,playlist-modify-private,playlist-read-private,playlist-read-collaborative,user-follow-read";

  String codeVerifier = _generateCodeVerifier();
  await _storeCodeVerifier(
      codeVerifier); // Store the code verifier for later use
  String codeChallenge = await _generateCodeChallenge(codeVerifier);

  Uri authUrl = Uri.parse("https://accounts.spotify.com/authorize")
      .replace(queryParameters: {
    'response_type': 'code',
    'client_id': clientId,
    'scope': scope,
    'redirect_uri': redirectUri,
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
  });

  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SpotifyLoginScreen(authUrl: authUrl.toString()),
    ),
  );

  // Use this method to show the SnackBar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  // Assuming result is a List<String> of selected genres
  if (result == null) {
    showSnackBar("Login failed.");
    return;
  }

  final data = await exchangeCodeForToken(result);
  if (data == null) {
    showSnackBar("Failed to exchange access tokens.");
    return;
  }

  final accessToken = data['access_token'] as String;

  final user = await _fetchUserProfile(accessToken);
  if (user != null) {
    final refreshToken = data['refresh_token'] as String;

    final expiresIn = data['expires_in'] as int;
    final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));

    const storage = FlutterSecureStorage();
    await storage.write(key: 'refreshToken', value: refreshToken);
    await storage.write(
        key: 'expirationDate', value: expirationDate.toIso8601String());

    Provider.of<AppContext>(context, listen: false)
        .login(user, accessToken, refreshToken, expirationDate);
    showSnackBar('Logged in successfully');
  } else {
    showSnackBar('Login failed');
  }
}

Future<User?> _fetchUserProfile(String token) async {
  var response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    var data = json.decode(response.body);

    var user = User.fromJson(data);

    return user;
  } else {
    return null;
  }
}

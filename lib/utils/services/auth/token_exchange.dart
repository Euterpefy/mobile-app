import 'dart:convert';
import 'package:euterpefy/utils/services/auth/spotify_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<dynamic> exchangeCodeForToken(String authorizationCode) async {
  final String? codeVerifier = await getCodeVerifier();
  if (codeVerifier == null) {
    return null;
  }
  final Uri tokenUri = Uri.parse("https://accounts.spotify.com/api/token");
  final response = await http.post(
    tokenUri,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'client_id': dotenv.env['SPOTIFY_CLIENT_ID']!,
      'grant_type': 'authorization_code',
      'code': authorizationCode,
      'redirect_uri': dotenv.env['REDIRECT_URI']!,
      'code_verifier': codeVerifier,
    },
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    return body;
  } else {
    // Handle errors or throw an exception
    print('Failed to exchange authorization code for token');
    return null;
  }
}

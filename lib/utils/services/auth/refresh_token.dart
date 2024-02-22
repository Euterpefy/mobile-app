import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> refreshAccessToken(String refreshToken) async {
  const storage = FlutterSecureStorage();
  final Uri tokenUri = Uri.parse("https://accounts.spotify.com/api/token");
  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;

  final response = await http.post(
    tokenUri,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': clientId,
    },
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    final newAccessToken = body['access_token'];
    final newRefreshToken = body['refresh_token'] ?? refreshToken;
    final expiresIn = body['expires_in'];
    final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));

    // Store the new tokens and expiration date
    await storage.write(key: 'accessToken', value: newAccessToken);
    await storage.write(key: 'refreshToken', value: newRefreshToken);
    await storage.write(
        key: 'expirationDate', value: expirationDate.toIso8601String());

    return {
      'accessToken': newAccessToken,
      'refreshToken': newRefreshToken,
      'expirationDate': expirationDate.toIso8601String(),
    };
  } else {
    // Handle error or token refresh failure
    return null;
  }
}

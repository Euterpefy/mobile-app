import 'package:euterpefy/services/spotify_service.dart';
import 'package:euterpefy/models/user.dart';
import 'package:flutter/material.dart';

class AppContext extends ChangeNotifier {
  User? _user;
  SpotifyService? _spotifyService;

  User? get user => _user;
  SpotifyService? get spotifyService => _spotifyService;

  AppContext();

  void login(User user, String accessToken, String refreshToken,
      DateTime expirationDate) {
    _user = user;
    _spotifyService = SpotifyService(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expirationDate: expirationDate,
      onAuthFail: onAuthenticationFailure,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    _spotifyService = null;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void onAuthenticationFailure() {
    _user = null;
    _spotifyService = null;
    notifyListeners();
  }
}

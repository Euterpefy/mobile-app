import 'package:euterpefy/services/spotify_service.dart';
import 'package:euterpefy/models/user.dart';
import 'package:flutter/material.dart';

class AppContext extends ChangeNotifier {
  User? _user;
  String? _token;
  SpotifyService? _spotifyService;

  User? get user => _user;
  String? get token => _token;
  SpotifyService? get spotifyService => _spotifyService;

  AppContext() {
    _updateSpotifyService();
  }

  void _updateSpotifyService() {
    if (_token != null) {
      _spotifyService = SpotifyService(
        accessToken: _token!,
        onAuthFail: onAuthenticationFailure, // Pass the method as a callback
      );
    } else {
      _spotifyService = null;
    }
  }

  void login(User user, String token) {
    _user = user;
    _token = token;
    _updateSpotifyService();
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    _updateSpotifyService();
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    _updateSpotifyService();
    notifyListeners();
  }

  void onAuthenticationFailure() {
    _token = null;
    _user = null;
    _updateSpotifyService();
    notifyListeners();
  }
}

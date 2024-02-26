import 'package:euterpefy/services/spotify_service.dart';
import 'package:euterpefy/models/user.dart';
import 'package:flutter/material.dart';

class AppContext extends ChangeNotifier {
  User? _user;
  SpotifyService? _spotifyService;
  ThemeMode _selectedThemeMode = ThemeMode.system;

  User? get user => _user;
  ThemeMode get selectedThemeMode => _selectedThemeMode;
  SpotifyService? get spotifyService => _spotifyService;

  AppContext();

  void login(User user, String accessToken, String refreshToken,
      DateTime expirationDate) {
    _user = user;
    _spotifyService = SpotifyService(
      userId: user.id,
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

  void setTheme(String themeMode) {
    _selectedThemeMode = themeMode == "system"
        ? ThemeMode.system
        : themeMode == "dark"
            ? ThemeMode.dark
            : ThemeMode.light;
    notifyListeners();
  }
}

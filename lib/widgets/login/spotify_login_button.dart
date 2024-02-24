// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/utils/services/auth/spotify_login.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/widgets/spotify_logo.dart';
import 'package:flutter/material.dart';

class SpotifyLoginButton extends StatelessWidget {
  const SpotifyLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => initiateSpotifyLogin(context),
      title: ElevatedButton.icon(
          onPressed: () => initiateSpotifyLogin(context),
          icon: const SpotifyLogo(),
          label: const Text(
            'Login with Spotify',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: elevatedButtonStyle(Colors.black, Colors.white)),
    );
  }
}

// lib/views/home/home.dart

// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/models/user.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/browse_section.dart';
import 'package:euterpefy/views/home/widgets/euterperfy_playlists.dart';
import 'package:euterpefy/views/home/widgets/featured_playlists.dart';
import 'package:euterpefy/views/home/widgets/generating_section.dart';
import 'package:euterpefy/views/home/widgets/drawer.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:euterpefy/utils/services/spotify/get_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> login() async {
    final token = await getTokenOrLogin(context);
    if (token != null) {
      await _storage.write(key: 'spotifyToken', value: token);
      _fetchUserProfile(token);
      Navigator.pop(context); // Close the drawer
      _showSnackBar('Logged in successfully');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'spotifyToken');

    Navigator.pop(context); // Close the drawer
    _showSnackBar('Logged out successfully');

    Provider.of<AppContext>(context, listen: false)
        .logout(); // Update AppContext state
  }

  Future<void> _fetchUserProfile(String token) async {
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Create a User object from the data
      var user = User.fromJson(data);
      // Update global user state

      Provider.of<AppContext>(context, listen: false).login(user, token);
    } else {
      await _storage.delete(key: 'spotifyToken');

      Provider.of<AppContext>(context, listen: false).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, widget.title),
      drawer: CustomDrawer(
        login: login,
        logout: logout,
      ),
      body: const SingleChildScrollView(
        // Wrap the content with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Section(child: BrowseSection()),
              Section(child: PlaylistGeneratingSection()),
              Section(child: FeaturedPlaylistsSection()),
              EuterpefyPlaylistSection(),
            ],
          ),
        ),
      ),
    );
  }
}

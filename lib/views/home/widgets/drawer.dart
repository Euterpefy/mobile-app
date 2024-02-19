// lib/views/home/widgets/drawer.dart

import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final Future<void> Function() login;
  final Future<void> Function() logout;

  const CustomDrawer({
    super.key,
    required this.login,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AppContext>(context, listen: false).user != null;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CustomDrawerHeader(),
          if (!isLoggedIn)
            ListTile(
              title: ElevatedButton.icon(
                onPressed: login,
                icon: SvgPicture.asset(
                  'assets/images/spotify_icon.svg',
                  height: 24.0,
                  width: 24.0,
                ),
                label: const Text('Login with Spotify'),
                style: elevatedButtonStyle(Colors.black, Colors.white),
              ),
            )
          else
            ListTile(
              title: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: elevatedButtonStyle(Colors.black, Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppContext>(context).user;
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: user != null
          ? Column(
              children: [
                AvatarIcon(
                    userAvatar: user.images != null && user.images!.isNotEmpty
                        ? user.images![0].url
                        : null,
                    userName: user.displayName),
                const SizedBox(height: 8),
                Text(
                  user.displayName ?? user.id,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login for more features and better generations',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

class AvatarIcon extends StatelessWidget {
  final String? userName;
  final String? userAvatar;

  const AvatarIcon({super.key, this.userName, this.userAvatar});

  @override
  Widget build(BuildContext context) {
    return userAvatar != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(userAvatar!),
            radius: 40,
          )
        : CircleAvatar(
            backgroundColor: Colors.green[200],
            radius: 40,
            child: Text(
              userName != null && userName!.isNotEmpty ? userName![0] : "S",
              style: const TextStyle(fontSize: 24.0),
            ),
          );
  }
}

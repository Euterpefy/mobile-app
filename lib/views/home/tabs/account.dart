// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/themes/appearance_select.dart';
import 'package:euterpefy/widgets/login/spotify_login_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({
    super.key,
  });

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive

  final _storage = const FlutterSecureStorage();
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> logout() async {
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'expiresIn');

    _showSnackBar('Logged out successfully');

    Provider.of<AppContext>(context, listen: false)
        .logout(); // Update AppContext state
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Need to call super.build
    final theme = Theme.of(context);
    final appContext = Provider.of<AppContext>(context, listen: true);
    final user = appContext.user;
    return SingleChildScrollView(
      child: Column(children: [
        ListTile(
          tileColor: theme.colorScheme.primaryContainer,
          title: Container(
            constraints: const BoxConstraints(minHeight: 200),
            alignment: Alignment.center,
            child: user != null
                ? Column(
                    children: [
                      AvatarIcon(
                          userAvatar:
                              user.images != null && user.images!.isNotEmpty
                                  ? user.images![0].url
                                  : null,
                          userName: user.displayName),
                      const SizedBox(height: 8),
                      Text(
                        user.displayName ?? user.id,
                        style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text('${user.followers.total} followers')
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login for more features and better generations',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
        if (user == null)
          const Column(
            children: [SpotifyLoginButton()],
          )
        else
          ListTile(
            title: const Text('Appearance'),
            subtitle: Text('Theme: ${appContext.selectedThemeMode.name}'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AppearanceScreen(
                          currentThemeMode: appContext.selectedThemeMode.name,
                          currentColor: Colors.black)))
            },
          ),
        ListTile(
          title: ElevatedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: elevatedButtonStyle(Colors.black, Colors.white),
          ),
        ),
      ]),
    );
  }
}

class AvatarIcon extends StatelessWidget {
  final String? userName;
  final String? userAvatar;

  const AvatarIcon({super.key, this.userName, this.userAvatar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return userAvatar != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(userAvatar!),
            radius: 45,
          )
        : CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            radius: 45,
            child: Text(
              userName != null && userName!.isNotEmpty ? userName![0] : "S",
              style:
                  TextStyle(fontSize: 28.0, color: theme.colorScheme.onPrimary),
            ),
          );
  }
}

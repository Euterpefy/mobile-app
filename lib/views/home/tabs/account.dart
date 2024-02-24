// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
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
    final user = Provider.of<AppContext>(context, listen: true).user;
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
            radius: 40,
          )
        : CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            radius: 40,
            child: Text(
              userName != null && userName!.isNotEmpty ? userName![0] : "S",
              style:
                  TextStyle(fontSize: 24.0, color: theme.colorScheme.onPrimary),
            ),
          );
  }
}

import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class AppearanceScreen extends StatefulWidget {
  final String currentThemeMode;
  final Color currentColor;

  const AppearanceScreen({
    super.key,
    required this.currentThemeMode,
    required this.currentColor,
  });

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _applyChanges(String themeMode) {
    final appContext = Provider.of<AppContext>(context, listen: false);
    appContext.setTheme(themeMode);
    const storage = FlutterSecureStorage();
    storage.write(key: "${appContext.user!.id}/themeMode", value: themeMode);
  }

  Map<String, Map<String, dynamic>> themes = {
    "light": {"title": "Light Theme", "icon": Icons.light_mode},
    "dark": {"title": "Dark Theme", "icon": Icons.dark_mode},
    "system": {"title": "Auto (system)", "icon": Icons.settings_suggest}
  };

  @override
  Widget build(BuildContext context) {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: customAppBar(context, "Appearance"),
      body: SingleChildScrollView(
        child: Column(
          children: themes.entries
              .map((e) => ListTile(
                    selectedTileColor: theme.colorScheme.inversePrimary,
                    selectedColor: theme.colorScheme.onBackground,
                    selected: e.key == appContext.selectedThemeMode.name,
                    title: Text(e.value['title']),
                    leading: Icon(e.value['icon']),
                    onTap: () => _applyChanges(e.key),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

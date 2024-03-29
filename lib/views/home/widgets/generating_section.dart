import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/views/tracks_generating/advanced_generator.dart';
import 'package:euterpefy/views/tracks_generating/genre_selection.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:flutter/material.dart';

class PlaylistGeneratingSection extends StatefulWidget {
  const PlaylistGeneratingSection({super.key});

  @override
  State<PlaylistGeneratingSection> createState() =>
      _PlaylistGeneratingSectionState();
}

class _PlaylistGeneratingSectionState extends State<PlaylistGeneratingSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SectionTitle(title: 'Generate your playlists'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GenreSelectionScreen()),
                );
              },
              style: outlinedButtonStyle(theme.colorScheme.onPrimaryContainer),
              child: const Text('Quick Generating'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdvancedGenerationScreen()),
                );
              },
              style: elevatedButtonStyle(theme.colorScheme.primaryContainer,
                  theme.colorScheme.onPrimaryContainer),
              child: const Text('Advanced Generating'),
            ),
          ],
        ),
      ],
    );
  }
}

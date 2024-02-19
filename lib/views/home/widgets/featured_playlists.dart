// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/models/playlist.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturedPlaylistsSection extends StatefulWidget {
  final String? locale;
  final String sectionTitle;

  const FeaturedPlaylistsSection({
    super.key,
    this.locale,
    this.sectionTitle = "Featured Playlists",
  });

  @override
  State<FeaturedPlaylistsSection> createState() =>
      _FeaturedPlaylistsSectionState();
}

class _FeaturedPlaylistsSectionState extends State<FeaturedPlaylistsSection> {
  Future<List<SimplifiedPlaylist>>? _categoriesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePlaylistsFuture();
  }

  void _updatePlaylistsFuture() {
    final appContext = Provider.of<AppContext>(context);
    _categoriesFuture = appContext.spotifyService
        ?.fetchFeaturedPlaylists(locale: widget.locale);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: widget.sectionTitle),
        if (_categoriesFuture != null)
          FutureBuilder<List<SimplifiedPlaylist>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final playlists = snapshot.data!;
                return _buildPlaylistsListView(playlists);
              } else if (snapshot.hasError) {
                return Text("Error fetching categories: ${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          )
        else
          Text(
            "Log in to browse featured playlists.",
            style: Theme.of(context).textTheme.labelLarge,
          ),
      ],
    );
  }

  Widget _buildPlaylistsListView(List<SimplifiedPlaylist> categories) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildPlaylistCard(category);
        },
      ),
    );
  }

  Widget _buildPlaylistCard(SimplifiedPlaylist playlist) {
    return GestureDetector(
      onTap: () async {
        // Assuming 'fetchPlaylistTracks' is a method in SpotifyService
        try {
          final tracks = await Provider.of<AppContext>(context, listen: false)
              .spotifyService
              ?.fetchPlaylistTracks(playlist.id);

          if (tracks != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistImportView(
                  title: playlist.name,
                  tracks: tracks,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load playlist details.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 160),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                playlist.images.first.url,
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150, // Set maximum width for the text
                ),
                child: Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis for overflowed text
                  maxLines: 2, // Allow text wrapping up to two lines
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

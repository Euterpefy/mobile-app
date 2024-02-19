import 'package:euterpefy/models/euterpefy_playlist.dart';
import 'package:euterpefy/utils/color.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EuterpefyPlaylistSection extends StatefulWidget {
  const EuterpefyPlaylistSection({
    super.key,
  });

  @override
  State<EuterpefyPlaylistSection> createState() =>
      _EuterpefyPlaylistSectionState();
}

class _EuterpefyPlaylistSectionState extends State<EuterpefyPlaylistSection> {
  Future<List<EuterpefyPlaylist>>? _playlistsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playlistsFuture = _loadPlaylists();
  }

  Future<List<EuterpefyPlaylist>> _loadPlaylists() async {
    final appContext = Provider.of<AppContext>(context);
    final spotifyService = appContext.spotifyService;
    if (spotifyService != null) {
      final appPlaylists = await spotifyService.generateAppPlaylists();
      final genreBasedPlaylists =
          await spotifyService.generateGenreBasedPlaylists();
      return [...appPlaylists, ...genreBasedPlaylists];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EuterpefyPlaylist>>(
      future: _playlistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // No playlists available
        } else {
          // Playlists are loaded
          return Column(
            children: [
              const SectionTitle(title: "For You"),
              Column(
                children: snapshot.data!
                    .map((playlist) => _buildPlaylistCard(context, playlist))
                    .toList(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPlaylistCard(BuildContext context, EuterpefyPlaylist playlist) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistImportView(
              title: playlist.name,
              tracks: playlist.tracks,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        color: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlaylistCover(playlist),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                      color: whiteFloral,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              if (playlist.description != null)
                Text(
                  playlist.description!,
                  style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCover(EuterpefyPlaylist playlist) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: playlist.tracks
                .take(2)
                .map((t) => t.album.images.first.url)
                .toList()
                .map((url) => Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Ensures the image is square
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ))
                .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: playlist.tracks
                .skip(2)
                .take(2)
                .map((t) => t.album.images.first.url)
                .toList()
                .map((url) => Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Ensures the image is square
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}

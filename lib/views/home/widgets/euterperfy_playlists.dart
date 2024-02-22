import 'dart:async';

import 'package:euterpefy/models/euterpefy_playlist.dart';
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
  final List<EuterpefyPlaylist> _playlists = [];
  StreamSubscription<EuterpefyPlaylist>? _playlistSubscription;

  @override
  void initState() {
    super.initState();
    initPlaylists();

    // Listen to changes in AppContext
    final appContext = Provider.of<AppContext>(context, listen: false);
    appContext.addListener(initPlaylists);
  }

  @override
  void dispose() {
    // Cancel the stream subscription to prevent memory leaks
    _playlistSubscription?.cancel();
    Provider.of<AppContext>(context, listen: false)
        .removeListener(initPlaylists);
    super.dispose();
  }

  void initPlaylists() {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;

    // Clear existing data and subscription to start fresh
    setState(() => _playlists.clear());
    _playlistSubscription?.cancel();

    if (spotifyService != null) {
      spotifyService.generateAndEmitPlaylists();
      _playlistSubscription = spotifyService.playlistStream.listen(
        (playlist) {
          setState(() {
            _playlists.add(playlist);
          });
        },
        onError: (error) {
          print("Error receiving playlist: $error");
        },
      );
    } else {
      // Spotify service is null, indicating the user is not logged in
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;
    // If not logged in, show login prompt
    if (_playlists.isEmpty) {
      if (spotifyService == null) {
        return const Center(
          child: Text('Log in for more features'),
        );
      } else {
        return const Center(
          child: Text('Generating playlists for you..'),
        );
      }
    }

    // Proceed with building the UI as before
    return Column(
      children: [
        const SectionTitle(title: "For You"),
        Column(
          children: _playlists
              .map((playlist) => _buildPlaylistCard(context, playlist))
              .toList(),
        ),
      ],
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
        color: theme.colorScheme.secondaryContainer,
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
                  style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              if (playlist.description != null)
                Text(
                  playlist.description!,
                  style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
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

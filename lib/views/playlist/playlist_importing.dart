// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:euterpefy/models/playlists.dart';
import 'package:euterpefy/models/tracks.dart';
import 'package:euterpefy/services/spotify_service.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/playlist/playlist_imports/import_ask_dialog.dart';
import 'package:euterpefy/views/playlist/playlist_imports/import_playlist_dialog.dart';
import 'package:euterpefy/views/playlist/playlist_imports/track_item.dart';
import 'package:euterpefy/widgets/spotify_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class PlaylistImportView extends StatefulWidget {
  final String title;
  final List<Track> tracks;

  const PlaylistImportView({
    super.key,
    required this.title,
    required this.tracks,
  });

  @override
  State<PlaylistImportView> createState() => _PlaylistImportViewState();
}

class _PlaylistImportViewState extends State<PlaylistImportView> {
  late List<Track> _tracks;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTrackId;

  @override
  void initState() {
    super.initState();
    setState(() {
      _tracks = List.from(widget.tracks);
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onTrackButtonPressed(Track track) {
    if (track.previewUrl != null) {
      if (_playingTrackId == track.id) {
        _stopPreview();
      } else {
        _playPreview(track.id, track.previewUrl);
      }
    } else {
      _showSnackBar('Preview is not available for this track.');
    }
  }

  void _playPreview(String trackId, String? url) async {
    if (url != null) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() => _playingTrackId = trackId);
      _audioPlayer.onPlayerComplete
          .listen((_) => setState(() => _playingTrackId = null));
      _showSnackBar('Playing track preview.');
    }
  }

  void _stopPreview() async {
    await _audioPlayer.stop();
    setState(() => _playingTrackId = null);
    _showSnackBar('Stopped playing preview.');
  }

  void _removeTrack(Track track, int index) {
    setState(() {
      _tracks.removeAt(index);
    });
    _showSnackBar('${track.name} removed from the playlist.');
  }

  // Use this method to show the SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        title: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '${_tracks.length} Tracks',
              style: theme.textTheme.titleSmall!
                  .copyWith(fontWeight: FontWeight.w500),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Slide Track to the left to remove',
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                var track = _tracks[index];
                bool isCurrentTrackPlaying = _playingTrackId == track.id;
                return SlidableTrackItem(
                  track: track,
                  index: index,
                  isCurrentTrackPlaying: isCurrentTrackPlaying,
                  onTrackPressed: () => _onTrackButtonPressed(track),
                  onRemovePressed: () => _removeTrack(track, index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importPlaylist(),
        label: const Row(
          children: [
            Text('Import to Spotify'),
            SizedBox(
              width: 8,
            ),
            SpotifyLogo()
          ],
        ),
        icon: Icon(Platform.isIOS
            ? CupertinoIcons.music_albums_fill
            : Icons.playlist_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _importPlaylist() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final user = appContext.user;
    final spotifyService = appContext.spotifyService;
    if (spotifyService == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to import playlists.')));
      return;
    }

    // This could include showing dialogs for creating a new playlist or selecting an existing one.
    showDialog(
      context: context,
      builder: (BuildContext importContext) {
        return ImportAskDialog(
          onImportToExisting: () async {
            // Fetch playlists
            final playlists = await spotifyService.getCurrentUserPlaylists();
            if (playlists == null || playlists.items.isEmpty) {
              // Handle case where no playlists are returned or an error occurs
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('No playlists found. Please try again later.')),
              );
              return;
            }

            // Existing logic to create a new playlist
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text(
                    'Select a Playlist',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: playlists.items.length,
                      itemBuilder: (BuildContext itemBuildContext, int index) {
                        final coverImages = playlists.items[index].images;
                        return ListTile(
                          leading: coverImages.isNotEmpty
                              ? Image.network(coverImages.first.url)
                              : const SizedBox(
                                  width: 55,
                                  child: SpotifyLogo(),
                                ),
                          title: Text(
                            playlists.items[index].name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                              '${playlists.items[index].tracks.total} tracks'),
                          onTap: () {
                            // Import tracks into the selected playlist
                            _importTracksToPlaylist(spotifyService,
                                playlists.items[index].id, _tracks);
                            Navigator.of(dialogContext)
                                .pop(); // Close the dialog
                          },
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(), // Close the dialog
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          onCreateNew: () {
            // Existing logic to create a new playlist
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return PlaylistCreationDialog(
                  onCreate: (playlistName, isPublic, isCollaborative,
                      description) async {
                    _createPlaylist(
                        await spotifyService.getAccessToken(),
                        playlistName,
                        isPublic,
                        isCollaborative,
                        description,
                        _tracks.map((e) => e.id).toList());
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createPlaylist(String token, String playlistName, bool isPublic,
      bool isCollaborative, String? description, List<String> trackIds) async {
    final appContext = Provider.of<AppContext>(context, listen: false);

    final user = appContext.user;
    final spotifyService = appContext.spotifyService!;
    if (user == null) {
      return;
    }
    _showSnackBar("Creating playlist");
    final Playlist? playlistCreated = await spotifyService.createPlaylist(
        user.id, playlistName,
        isPublic: isPublic,
        isCollaborative: isCollaborative,
        description: description);

    if (playlistCreated == null) {
      _showSnackBar("Failed to create playlist.");
      return;
    }
    if (await spotifyService.addTracksToPlaylist(
        playlistCreated.id, trackIds)) {
      _showSnackBar("Playlist imported successfully.");
    } else {
      _showSnackBar("Failed to add tracks to playlist.");
    }
  }

  Future<void> _importTracksToPlaylist(SpotifyService spotifyService,
      String playlistId, List<Track> tracks) async {
    // Assuming you have a method to add tracks to a playlist
    final success = await spotifyService.addTracksToPlaylist(
        playlistId, tracks.map((track) => track.id).toList());

    if (success) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracks imported successfully.')),
      );
    } else {
      // Handle failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import tracks.')),
      );
    }
  }
}

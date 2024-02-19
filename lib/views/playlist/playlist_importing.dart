import 'package:euterpefy/models/playlist.dart';
import 'package:euterpefy/models/spotify_models.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:euterpefy/widgets/playlist_imports/import_ask_dialog.dart';
import 'package:euterpefy/widgets/playlist_imports/import_playlist_dialog.dart';
import 'package:euterpefy/widgets/playlist_imports/track_item.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTrackId;
  late List<Track> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(widget.tracks);
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, widget.title),
      body: ListView.builder(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importPlaylist(),
        label: const Text('Import to Spotify'),
        icon: const Icon(Icons.playlist_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _importPlaylist() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final user = appContext.user;
    final spotifyService = appContext.spotifyService;
    final token = appContext.token;
    if (spotifyService == null || user == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to import playlists.')));
      return;
    }

    // This could include showing dialogs for creating a new playlist or selecting an existing one.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImportAskDialog(
          onImportToExisting: () {
            // Implement the logic to display a list of existing playlists
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
                        token,
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
}

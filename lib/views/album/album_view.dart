import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:euterpefy/extensions/string.dart';
import 'package:euterpefy/models/albums.dart';
import 'package:euterpefy/models/tracks.dart';
import 'package:flutter/material.dart';

class AlbumView extends StatefulWidget {
  final Album album;
  const AlbumView({super.key, required this.album});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTrackId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

// Use this method to show the SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onTrackButtonPressed(SimplifiedTrack track) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          title: Text(
            widget.album.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAlbumCoverImage(),
            Text(widget.album.name,
                style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary)),
            Text(
              "${widget.album.albumType.capitalize()} • ${widget.album.totalTracks} Tracks",
              style: theme.textTheme.labelLarge!
                  .copyWith(color: theme.colorScheme.secondary),
            ),
            // Tracks
            for (SimplifiedTrack track in widget.album.tracks.items)
              SimplifiedTrackTile(
                index: widget.album.tracks.items.indexOf(track) + 1,
                track: track,
                isCurrentTrackPlaying: _playingTrackId == track.id,
                onTrackPressed: () => _onTrackButtonPressed(track),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCoverImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blurry background with a color overlay for blending
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 10, sigmaY: 90, tileMode: TileMode.decal),
            child: Image.network(
              widget.album.images.first.url,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
            padding: const EdgeInsets.fromLTRB(80, 32, 80, 8),
            child: Image.network(
              widget.album.images.first.url,
              width: MediaQuery.of(context).size.width,
            ))
      ],
    );
  }
}

class SimplifiedTrackTile extends StatelessWidget {
  final int index;
  final SimplifiedTrack track;
  final bool isCurrentTrackPlaying;
  final VoidCallback onTrackPressed;

  const SimplifiedTrackTile({
    super.key,
    required this.index,
    required this.track,
    required this.isCurrentTrackPlaying,
    required this.onTrackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Text(
        '$index',
        style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onBackground, fontWeight: FontWeight.w700),
      ),
      title: Text(
        track.name,
        style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onBackground, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        track.artists.map((a) => a.name).join(', '),
        style: theme.textTheme.labelMedium!
            .copyWith(color: theme.colorScheme.secondary),
      ),
      trailing: IconButton(
        icon: Icon(isCurrentTrackPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: onTrackPressed,
        color: track.previewUrl == null ? Colors.grey : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:euterpefy/models/spotify_models.dart'; // Assuming Track model is here

class SlidableTrackItem extends StatelessWidget {
  final Track track;
  final int index;
  final bool isCurrentTrackPlaying;
  final VoidCallback onTrackPressed;
  final VoidCallback onRemovePressed;

  const SlidableTrackItem({
    super.key,
    required this.track,
    required this.index,
    required this.isCurrentTrackPlaying,
    required this.onTrackPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(track.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (_) => onRemovePressed(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.remove_circle,
            label: 'Remove',
          ),
        ],
      ),
      child: ListTile(
        leading: track.album.images.isNotEmpty
            ? Image.network(track.album.images.first.url)
            : const Icon(Icons.music_note),
        title: Text(track.name),
        subtitle: Text(track.artists.map((a) => a.name).join(', ')),
        trailing: IconButton(
          icon: Icon(isCurrentTrackPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: onTrackPressed,
          color: track.previewUrl == null ? Colors.grey : null,
        ),
      ),
    );
  }
}

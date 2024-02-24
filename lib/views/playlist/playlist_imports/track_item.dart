import 'dart:io';

import 'package:euterpefy/models/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';

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
        title: Text(
          track.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Text(
          track.artists.map((a) => a.name).join(', '),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: IconButton(
          icon: Icon(isCurrentTrackPlaying
              ? (Platform.isIOS ? CupertinoIcons.pause_fill : Icons.pause)
              : (Platform.isIOS
                  ? (track.previewUrl == null
                      ? CupertinoIcons.play
                      : CupertinoIcons.play_fill)
                  : track.previewUrl == null
                      ? Icons.play_arrow_outlined
                      : Icons.play_arrow)),
          onPressed: onTrackPressed,
          color: track.previewUrl == null ? Colors.grey : null,
        ),
      ),
    );
  }
}

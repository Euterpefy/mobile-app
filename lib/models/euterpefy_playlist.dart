import 'package:euterpefy/models/spotify_models.dart';

class EuterpefyPlaylist {
  final String name;
  final String? description;
  final List<Track> tracks;

  EuterpefyPlaylist({
    this.description,
    required this.name,
    required this.tracks,
  });
}

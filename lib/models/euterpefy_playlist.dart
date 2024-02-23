import 'package:euterpefy/models/tracks.dart';

class EuterpefyPlaylist {
  final String type;
  final String? description;
  final List<Track> tracks;

  EuterpefyPlaylist({
    this.description,
    required this.type,
    required this.tracks,
  });

  // Convert a EuterpefyPlaylist object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }

  // Convert a Map object into a EuterpefyPlaylist object
  factory EuterpefyPlaylist.fromJson(Map<String, dynamic> json) {
    return EuterpefyPlaylist(
      type: json['type'],
      description: json['description'],
      tracks: (json['tracks'] as List<dynamic>)
          .map((trackJson) => Track.fromJson(trackJson))
          .toList(),
    );
  }
}

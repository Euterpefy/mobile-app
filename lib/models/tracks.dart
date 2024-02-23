import 'package:euterpefy/models/albums.dart';
import 'package:euterpefy/models/spotify_models.dart';

class Track {
  final String id;
  final String name;
  final List<TrackArtist> artists;
  final SimplifiedAlbum album;
  final int durationMs;
  final String? previewUrl; // nullable
  final ExternalUrls externalUrls;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
    this.previewUrl,
    required this.externalUrls,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      artists: List<TrackArtist>.from(
          json['artists'].map((x) => TrackArtist.fromJson(x))),
      album: SimplifiedAlbum.fromJson(json['album']),
      durationMs: json['duration_ms'],
      previewUrl: json['preview_url'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': List<dynamic>.from(artists.map((x) => x.toJson())),
      'album': album.toJson(),
      'duration_ms': durationMs,
      'preview_url': previewUrl,
      'external_urls': externalUrls.toJson(),
    };
  }
}

class TrackArtist {
  final String id;
  final String name;

  TrackArtist({required this.id, required this.name});

  factory TrackArtist.fromJson(Map<String, dynamic> json) {
    return TrackArtist(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SimplifiedTrack {
  final String id;
  final String name;
  final List<TrackArtist> artists;
  final int durationMs;
  final String? previewUrl;
  final ExternalUrls externalUrls;

  SimplifiedTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.durationMs,
    this.previewUrl,
    required this.externalUrls,
  });

  factory SimplifiedTrack.fromJson(Map<String, dynamic> json) {
    return SimplifiedTrack(
      id: json['id'],
      name: json['name'],
      artists: List<TrackArtist>.from(
          json['artists'].map((x) => TrackArtist.fromJson(x))),
      durationMs: json['duration_ms'],
      previewUrl: json['preview_url'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': List<dynamic>.from(artists.map((x) => x.toJson())),
      'duration_ms': durationMs,
      'preview_url': previewUrl,
      'external_urls': externalUrls.toJson(),
    };
  }
}

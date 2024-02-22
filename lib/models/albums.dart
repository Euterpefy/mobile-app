import 'package:euterpefy/models/pagination.dart';
import 'package:euterpefy/models/spotify_models.dart';
import 'package:euterpefy/models/tracks.dart';

class Album {
  final String albumType;
  final int totalTracks;
  final ExternalUrls externalUrls;
  final String href;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final String releaseDate;
  final String releaseDatePrecision;
  final String type;
  final String uri;
  final List<TrackArtist> artists;
  final PagedResponse<SimplifiedTrack> tracks;

  Album({
    required this.albumType,
    required this.totalTracks,
    required this.externalUrls,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.releaseDate,
    required this.releaseDatePrecision,
    required this.type,
    required this.uri,
    required this.artists,
    required this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumType: json['album_type'],
      totalTracks: json['total_tracks'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      href: json['href'],
      id: json['id'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      name: json['name'],
      releaseDate: json['release_date'],
      releaseDatePrecision: json['release_date_precision'],
      type: json['type'],
      uri: json['uri'],
      artists: List<TrackArtist>.from(
          json['artists'].map((x) => TrackArtist.fromJson(x))),
      tracks: PagedResponse<SimplifiedTrack>.fromJson(
          json['tracks'], (jsonItem) => SimplifiedTrack.fromJson(jsonItem)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_type': albumType,
      'total_tracks': totalTracks,
      'external_urls': externalUrls.toJson(),
      'href': href,
      'id': id,
      'images': List<dynamic>.from(images.map((x) => x.toJson())),
      'name': name,
      'release_date': releaseDate,
      'release_date_precision': releaseDatePrecision,
    };
  }
}

class SimplifiedAlbum {
  final String albumType;
  final int totalTracks;
  final ExternalUrls externalUrls;
  final String href;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final String releaseDate;
  final String releaseDatePrecision;
  final List<TrackArtist> artists;

  SimplifiedAlbum({
    required this.albumType,
    required this.totalTracks,
    required this.externalUrls,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.releaseDate,
    required this.releaseDatePrecision,
    required this.artists,
  });

  factory SimplifiedAlbum.fromJson(Map<String, dynamic> json) {
    return SimplifiedAlbum(
      albumType: json['album_type'],
      totalTracks: json['total_tracks'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      href: json['href'],
      id: json['id'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      name: json['name'],
      releaseDate: json['release_date'],
      releaseDatePrecision: json['release_date_precision'],
      artists: List<TrackArtist>.from(
          json['artists'].map((x) => TrackArtist.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_type': albumType,
      'total_tracks': totalTracks,
      'external_urls': externalUrls.toJson(),
      'href': href,
      'id': id,
      'images': List<dynamic>.from(images.map((x) => x.toJson())),
      'name': name,
      'release_date': releaseDate,
      'release_date_precision': releaseDatePrecision,
    };
  }
}

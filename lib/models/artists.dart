import 'package:euterpefy/models/spotify_models.dart';

class Artist {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final String spotifyUrl;
  final int followers;
  final List<String> genres;
  final int popularity;

  Artist(
      {required this.id,
      required this.name,
      required this.images,
      required this.spotifyUrl,
      required this.followers,
      required this.genres,
      required this.popularity});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      spotifyUrl: json['external_urls']['spotify'],
      followers: json['followers']['total'],
      genres: List<String>.from(json['genres']),
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': List<dynamic>.from(images.map((x) => x.toJson())),
    };
  }
}

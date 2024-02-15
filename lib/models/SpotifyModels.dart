// lib/SpotifyModels.dart

class Track {
  final String id;
  final String name;
  final List<TrackArtist> artists;
  final Album album;
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
      artists: List<TrackArtist>.from(json['artists'].map((x) => TrackArtist.fromJson(x))),
      album: Album.fromJson(json['album']),
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
      'preview_url': previewUrl, // No change needed here, as null is a valid value
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

class Artist {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final String spotifyUrl;
  final int followers;
  final List<String> genres;
  final int popularity;

  Artist({
    required this.id,
    required this.name,
    required this.images,
    required this.spotifyUrl,
    required this.followers,
    required this.genres,
    required this.popularity
  });

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

class Album {
  final String id;
  final String name;
  final String releaseDate;
  final List<SpotifyImage> images;

  Album({
    required this.id,
    required this.name,
    required this.releaseDate,
    required this.images,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      releaseDate: json['release_date'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'release_date': releaseDate,
      'images': List<dynamic>.from(images.map((x) => x.toJson())),
    };
  }
}

class SpotifyImage {
  final String url;
  final int? height;
  final int? width;

  SpotifyImage({required this.url, this.height, this.width});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url'],
      height: json['height'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'height': height,
      'width': width,
    };
  }
}

class ExternalUrls {
  final String spotify;

  ExternalUrls({required this.spotify});

  factory ExternalUrls.fromJson(Map<String, dynamic> json) {
    return ExternalUrls(
      spotify: json['spotify'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotify': spotify,
    };
  }
}

// lib/spotify_models.dart

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

class ExplicitContent {
  final bool filterEnabled;
  final bool filterLocked;

  ExplicitContent({required this.filterEnabled, required this.filterLocked});

  factory ExplicitContent.fromJson(Map<String, dynamic> json) {
    return ExplicitContent(
      filterEnabled: json['filter_enabled'],
      filterLocked: json['filter_locked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filter_enabled': filterEnabled,
      'filter_locked': filterLocked,
    };
  }
}

class Followers {
  final int total;

  Followers({required this.total});

  factory Followers.fromJson(Map<String, dynamic> json) {
    return Followers(
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
    };
  }
}

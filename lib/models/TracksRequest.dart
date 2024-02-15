class TracksRequest {
  final List<String> seedGenres;
  final List<String> seedArtists;
  final int minPopularity;
  final int maxPopularity;

  TracksRequest({
    this.seedGenres = const [],
    this.seedArtists = const [],
    this.minPopularity = 0,
    this.maxPopularity = 100,
  });

  factory TracksRequest.fromJson(Map<String, dynamic> json) {
    return TracksRequest(
      seedGenres: List<String>.from(json['seed_genres'] ?? const []),
      seedArtists: List<String>.from(json['seed_artists'] ?? const []),
      minPopularity: json['min_popularity'] ?? 0,
      maxPopularity: json['max_popularity'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seed_genres': seedGenres,
      'seed_artists': seedArtists,
      'min_popularity': minPopularity,
      'max_popularity': maxPopularity,
    };
  }
}

class TracksRequest {
  final List<String> seedGenres;
  final List<String> seedArtists;
  final List<String> seedTracks;
  final int limit;
  final String? market;
  final double? minAcousticness;
  final double? maxAcousticness;
  final double? targetAcousticness;
  final double? minDanceability;
  final double? maxDanceability;
  final double? targetDanceability;
  final int? minDurationMs;
  final int? maxDurationMs;
  final int? targetDurationMs;
  final double? minEnergy;
  final double? maxEnergy;
  final double? targetEnergy;
  final double? minInstrumentalness;
  final double? maxInstrumentalness;
  final double? targetInstrumentalness;
  final int? minKey;
  final int? maxKey;
  final int? targetKey;
  final double? minLiveness;
  final double? maxLiveness;
  final double? targetLiveness;
  final double? minLoudness;
  final double? maxLoudness;
  final double? targetLoudness;
  final int? minMode;
  final int? maxMode;
  final int? targetMode;
  final int minPopularity;
  final int maxPopularity;
  final int? targetPopularity;
  final double? minSpeechiness;
  final double? maxSpeechiness;
  final double? targetSpeechiness;
  final double? minTempo;
  final double? maxTempo;
  final double? targetTempo;
  final int? minTimeSignature;
  final int? maxTimeSignature;
  final int? targetTimeSignature;
  final double? minValence;
  final double? maxValence;
  final double? targetValence;

  TracksRequest({
    this.seedGenres = const [],
    this.seedArtists = const [],
    this.seedTracks = const [],
    this.limit = 20,
    this.market,
    this.minAcousticness,
    this.maxAcousticness,
    this.targetAcousticness,
    this.minDanceability,
    this.maxDanceability,
    this.targetDanceability,
    this.minDurationMs,
    this.maxDurationMs,
    this.targetDurationMs,
    this.minEnergy,
    this.maxEnergy,
    this.targetEnergy,
    this.minInstrumentalness,
    this.maxInstrumentalness,
    this.targetInstrumentalness,
    this.minKey,
    this.maxKey,
    this.targetKey,
    this.minLiveness,
    this.maxLiveness,
    this.targetLiveness,
    this.minLoudness,
    this.maxLoudness,
    this.targetLoudness,
    this.minMode,
    this.maxMode,
    this.targetMode,
    this.minPopularity = 0,
    this.maxPopularity = 100,
    this.targetPopularity,
    this.minSpeechiness,
    this.maxSpeechiness,
    this.targetSpeechiness,
    this.minTempo,
    this.maxTempo,
    this.targetTempo,
    this.minTimeSignature,
    this.maxTimeSignature,
    this.targetTimeSignature,
    this.minValence,
    this.maxValence,
    this.targetValence,
  });

  Map<String, dynamic> toJson() {
    return {
      'seed_genres': seedGenres,
      'seed_artists': seedArtists,
      'seed_tracks': seedTracks,
      'limit': limit,
      'market': market,
      'min_acousticness': minAcousticness,
      'max_acousticness': maxAcousticness,
      'target_acousticness': targetAcousticness,
      'min_danceability': minDanceability,
      'max_danceability': maxDanceability,
      'target_danceability': targetDanceability,
      'min_duration_ms': minDurationMs,
      'max_duration_ms': maxDurationMs,
      'target_duration_ms': targetDurationMs,
      'min_energy': minEnergy,
      'max_energy': maxEnergy,
      'target_energy': targetEnergy,
      'min_instrumentalness': minInstrumentalness,
      'max_instrumentalness': maxInstrumentalness,
      'target_instrumentalness': targetInstrumentalness,
      'min_key': minKey,
      'max_key': maxKey,
      'target_key': targetKey,
      'min_liveness': minLiveness,
      'max_liveness': maxLiveness,
      'target_liveness': targetLiveness,
      'min_loudness': minLoudness,
      'max_loudness': maxLoudness,
      'target_loudness': targetLoudness,
      'min_mode': minMode,
      'max_mode': maxMode,
      'target_mode': targetMode,
      'min_popularity': minPopularity,
      'max_popularity': maxPopularity,
      'target_popularity': targetPopularity,
      'min_speechiness': minSpeechiness,
      'max_speechiness': maxSpeechiness,
      'target_speechiness': targetSpeechiness,
      'min_tempo': minTempo,
      'max_tempo': maxTempo,
      'target_tempo': targetTempo,
      'min_time_signature': minTimeSignature,
      'max_time_signature': maxTimeSignature,
      'target_time_signature': targetTimeSignature,
      'min_valence': minValence,
      'max_valence': maxValence,
      'target_valence': targetValence,
    };
  }

  Map<String, dynamic> toStringJson() {
    return {
      'seed_genres': seedGenres.join(','),
      'seed_artists': seedArtists.join(','),
      'seed_tracks': seedTracks.join(','),
      'limit': limit.toString(),
      'market': market,
      'min_acousticness': minAcousticness,
      'max_acousticness': maxAcousticness,
      'target_acousticness': targetAcousticness,
      'min_danceability': minDanceability,
      'max_danceability': maxDanceability,
      'target_danceability': targetDanceability,
      'min_duration_ms': minDurationMs,
      'max_duration_ms': maxDurationMs,
      'target_duration_ms': targetDurationMs,
      'min_energy': minEnergy,
      'max_energy': maxEnergy,
      'target_energy': targetEnergy,
      'min_instrumentalness': minInstrumentalness,
      'max_instrumentalness': maxInstrumentalness,
      'target_instrumentalness': targetInstrumentalness,
      'min_key': minKey,
      'max_key': maxKey,
      'target_key': targetKey,
      'min_liveness': minLiveness,
      'max_liveness': maxLiveness,
      'target_liveness': targetLiveness,
      'min_loudness': minLoudness,
      'max_loudness': maxLoudness,
      'target_loudness': targetLoudness,
      'min_mode': minMode,
      'max_mode': maxMode,
      'target_mode': targetMode,
      'min_popularity': minPopularity.toString(),
      'max_popularity': maxPopularity.toString(),
      'target_popularity': targetPopularity,
      'min_speechiness': minSpeechiness,
      'max_speechiness': maxSpeechiness,
      'target_speechiness': targetSpeechiness,
      'min_tempo': minTempo,
      'max_tempo': maxTempo,
      'target_tempo': targetTempo,
      'min_time_signature': minTimeSignature,
      'max_time_signature': maxTimeSignature,
      'target_time_signature': targetTimeSignature,
      'min_valence': minValence,
      'max_valence': maxValence,
      'target_valence': targetValence,
    };
  }
}

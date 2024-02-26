import 'package:euterpefy/views/tracks_generating/advanced_criterias.dart';

class TracksRequest {
  late List<String> seedGenres;
  late List<String> seedArtists;
  late List<String> seedTracks;
  late int limit;
  late String? market;
  late double? minAcousticness;
  late double? maxAcousticness;
  late double? targetAcousticness;
  late double? minDanceability;
  late double? maxDanceability;
  late double? targetDanceability;
  late int? minDurationMs;
  late int? maxDurationMs;
  late int? targetDurationMs;
  late double? minEnergy;
  late double? maxEnergy;
  late double? targetEnergy;
  late double? minInstrumentalness;
  late double? maxInstrumentalness;
  late double? targetInstrumentalness;
  late int? minKey;
  late int? maxKey;
  late int? targetKey;
  late double? minLiveness;
  late double? maxLiveness;
  late double? targetLiveness;
  late double? minLoudness;
  late double? maxLoudness;
  late double? targetLoudness;
  late int? minMode;
  late int? maxMode;
  late int? targetMode;
  late int minPopularity;
  late int maxPopularity;
  late int? targetPopularity;
  late double? minSpeechiness;
  late double? maxSpeechiness;
  late double? targetSpeechiness;
  late double? minTempo;
  late double? maxTempo;
  late double? targetTempo;
  late int? minTimeSignature;
  late int? maxTimeSignature;
  late int? targetTimeSignature;
  late double? minValence;
  late double? maxValence;
  late double? targetValence;

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

  factory TracksRequest.fromJson(Map<String, dynamic> json) {
    return TracksRequest(
      seedGenres: json['seed_genres']?.split(',') ?? [],
      seedArtists: json['seed_artists']?.split(',') ?? [],
      seedTracks: json['seed_tracks']?.split(',') ?? [],
      limit: json['limit'] ?? 20,
      market: json['market'],
      minAcousticness: json['min_acousticness']?.toDouble(),
      maxAcousticness: json['max_acousticness']?.toDouble(),
      targetAcousticness: json['target_acousticness']?.toDouble(),
      minDanceability: json['min_danceability']?.toDouble(),
      maxDanceability: json['max_danceability']?.toDouble(),
      targetDanceability: json['target_danceability']?.toDouble(),
      minDurationMs: json['min_duration_ms'],
      maxDurationMs: json['max_duration_ms'],
      targetDurationMs: json['target_duration_ms'],
      minEnergy: json['min_energy']?.toDouble(),
      maxEnergy: json['max_energy']?.toDouble(),
      targetEnergy: json['target_energy']?.toDouble(),
      minInstrumentalness: json['min_instrumentalness']?.toDouble(),
      maxInstrumentalness: json['max_instrumentalness']?.toDouble(),
      targetInstrumentalness: json['target_instrumentalness']?.toDouble(),
      minKey: json['min_key'],
      maxKey: json['max_key'],
      targetKey: json['target_key'],
      minLiveness: json['min_liveness']?.toDouble(),
      maxLiveness: json['max_liveness']?.toDouble(),
      targetLiveness: json['target_liveness']?.toDouble(),
      minLoudness: json['min_loudness']?.toDouble(),
      maxLoudness: json['max_loudness']?.toDouble(),
      targetLoudness: json['target_loudness']?.toDouble(),
      minMode: json['min_mode'],
      maxMode: json['max_mode'],
      targetMode: json['target_mode'],
      minPopularity: ((json['min_popularity'] ?? 0) as num).toInt(),
      maxPopularity: ((json['max_popularity'] ?? 100) as num).toInt(),
      targetPopularity: json['target_popularity'],
      minSpeechiness: json['min_speechiness']?.toDouble(),
      maxSpeechiness: json['max_speechiness']?.toDouble(),
      targetSpeechiness: json['target_speechiness']?.toDouble(),
      minTempo: json['min_tempo']?.toDouble(),
      maxTempo: json['max_tempo']?.toDouble(),
      targetTempo: json['target_tempo']?.toDouble(),
      minTimeSignature: json['min_time_signature'],
      maxTimeSignature: json['max_time_signature'],
      targetTimeSignature: json['target_time_signature'],
      minValence: json['min_valence']?.toDouble(),
      maxValence: json['max_valence']?.toDouble(),
      targetValence: json['target_valence']?.toDouble(),
    );
  }
}

Map<String, dynamic> criteriaListToTrackRequestJson(
    List<String>? seedGenres,
    List<String>? seedArtists,
    List<String>? seedTracks,
    List<Criteria> criteriaList) {
  Map<String, dynamic> jsonMap = {};

  // Add seed genres, artists, and tracks if they are not null and contain elements
  if (seedGenres != null && seedGenres.isNotEmpty) {
    jsonMap['seed_genres'] = seedGenres.join(',');
  }
  if (seedArtists != null && seedArtists.isNotEmpty) {
    jsonMap['seed_artists'] = seedArtists.join(',');
  }
  if (seedTracks != null && seedTracks.isNotEmpty) {
    jsonMap['seed_tracks'] = seedTracks.join(',');
  }

  for (var criteria in criteriaList) {
    // Check if values.start is different from min
    if (criteria.values.start != criteria.min) {
      jsonMap["min_${criteria.label.toLowerCase().replaceAll(" ", "_")}"] =
          criteria.values.start;
    }

    // Check if values.end is different from max
    if (criteria.values.end != criteria.max) {
      jsonMap["max_${criteria.label.toLowerCase().replaceAll(" ", "_")}"] =
          criteria.values.end;
    }

    // If a target value is provided (assuming a target is a specific value within the range), it can be added as well
    // This assumes your Criteria class or the context where it's used allows identifying a 'target' value
    if (criteria.target != null) {
      jsonMap["target_${criteria.label.toLowerCase().replaceAll(" ", "_")}"] =
          criteria.target;
    }
  }

  return jsonMap;
}

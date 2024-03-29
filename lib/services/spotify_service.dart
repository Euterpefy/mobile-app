// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:euterpefy/models/albums.dart';
import 'package:euterpefy/models/artists.dart';
import 'package:euterpefy/models/categories.dart';
import 'package:euterpefy/models/euterpefy_playlist.dart';
import 'package:euterpefy/models/pagination.dart';
import 'package:euterpefy/models/playlists.dart';
import 'package:euterpefy/models/tracks.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/models/user.dart';
import 'package:euterpefy/services/cache_manager.dart';
import 'package:euterpefy/utils/services/auth/refresh_token.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class SpotifyService {
  final String baseUrl = 'https://api.spotify.com/v1';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String accessToken;
  String refreshToken;
  DateTime expirationDate;
  final Function onAuthFail;
  String userId;

  SpotifyService({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expirationDate,
    required this.onAuthFail,
  });

  static final CacheManager _cacheManager = CacheManager();
  static DateTime? _rateLimitResetTime;

  // StreamController for emitting playlists as they are generated
  final StreamController<EuterpefyPlaylist> _playlistStreamController =
      StreamController.broadcast();

  // Expose the stream of playlists
  Stream<EuterpefyPlaylist> get playlistStream =>
      _playlistStreamController.stream;

  // Remember to close the StreamController
  void dispose() {
    _playlistStreamController.close();
  }

  Future<String> getAccessToken() async {
    // Check if the current token is expired
    if (DateTime.now().isAfter(expirationDate)) {
      if (!await refreshServiceAccessToken()) {
        onAuthFail();
      }
    }
    return accessToken;
  }

  Future<bool> refreshServiceAccessToken() async {
    final storedRefreshToken = await _storage.read(key: 'refreshToken');

    if (storedRefreshToken == null) {
      return false;
    }

    final tokensData = await refreshAccessToken(storedRefreshToken);
    if (tokensData == null) {
      return false;
    }
    accessToken = tokensData['access_token'];
    refreshToken = tokensData['refresh_token'];
    expirationDate =
        DateTime.now().add(Duration(seconds: tokensData['expires_in'] as int));
    return true;
  }

  Future<void> _checkForAuthFailure(Response response) async {
    if (response.statusCode == 401) {
      onAuthFail();
    }
  }

  Future<dynamic> _getWithCaching(String url,
      {int cachingTime = 5, bool userUnique = false}) async {
    final cacheUrl = userUnique ? '$userId/$url' : url;
    // Check cache first
    if (_cacheManager.has(cacheUrl)) {
      return _cacheManager.get(cacheUrl);
    }

    // Check if we need to respect rate limiting
    if (_rateLimitResetTime != null &&
        DateTime.now().isBefore(_rateLimitResetTime!)) {
      final waitDuration = _rateLimitResetTime!.difference(DateTime.now());
      await Future.delayed(waitDuration);
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    // Handle rate limiting
    if (response.statusCode == 429) {
      int waitSeconds = int.parse(response.headers['Retry-After'] ?? '60');
      _rateLimitResetTime = DateTime.now().add(Duration(seconds: waitSeconds));
      return Future.delayed(
          Duration(seconds: waitSeconds), () => _getWithCaching(url));
    }

    // Reset rate limit reset time on successful request
    _rateLimitResetTime = null;

    // Cache the successful response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Adjust TTL as needed
      _cacheManager.set(cacheUrl, data, ttl: Duration(minutes: cachingTime));
      return data;
    } else {
      _checkForAuthFailure(response);
      // Handle other errors or return null to indicate an issue
      return null;
    }
  }

  Future<dynamic> _getNoCaching(
    String url,
  ) async {
    // Check if we need to respect rate limiting
    if (_rateLimitResetTime != null &&
        DateTime.now().isBefore(_rateLimitResetTime!)) {
      final waitDuration = _rateLimitResetTime!.difference(DateTime.now());
      await Future.delayed(waitDuration);
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    // Handle rate limiting
    if (response.statusCode == 429) {
      int waitSeconds = int.parse(response.headers['Retry-After'] ?? '60');
      _rateLimitResetTime = DateTime.now().add(Duration(seconds: waitSeconds));
      return Future.delayed(
          Duration(seconds: waitSeconds), () => _getWithCaching(url));
    }

    // Reset rate limit reset time on successful request
    _rateLimitResetTime = null;

    // Cache the successful response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Adjust TTL as needed
      return data;
    } else {
      _checkForAuthFailure(response);
      // Handle other errors or return null to indicate an issue
      return null;
    }
  }

  Future<dynamic> _postWithHandling(String url, String body) async {
    // Check rate limiting before making the request.
    if (_rateLimitResetTime != null &&
        DateTime.now().isBefore(_rateLimitResetTime!)) {
      final waitDuration = _rateLimitResetTime!.difference(DateTime.now());
      await Future.delayed(waitDuration);
    }

    final response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body);

    // Handle rate limiting.
    if (response.statusCode == 429) {
      int waitSeconds = int.parse(response.headers['Retry-After'] ?? '60');
      _rateLimitResetTime = DateTime.now().add(Duration(seconds: waitSeconds));
      return Future.delayed(
          Duration(seconds: waitSeconds), () => _postWithHandling(url, body));
    }

    // Reset rate limit reset time on successful request.
    _rateLimitResetTime = null;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _checkForAuthFailure(response);
      // Handle other errors or return null to indicate an issue.
      return null;
    }
  }

  Future<List<String>?> fetchSeedGenres() async {
    final data =
        await _getWithCaching("$baseUrl/recommendations/available-genre-seeds");
    if (data == null) return null;
    List<String> genres = (data['genres'] as List<dynamic>)
        .map((genre) => genre.toString())
        .toList();
    return genres;
  }

  Future<List<Artist>?> fetchSeedArtists(
      {required List<String> seedGenres}) async {
    final tracks = await generateRecommendations(
        TracksRequest(seedGenres: seedGenres.take(5).toList(), limit: 50));
    if (tracks.isEmpty) {
      return null;
    }
    // Extract all artist IDs from tracks, considering that a track can have multiple artists
    var allArtistIds = tracks
        .expand((track) => track.artists.map((artist) => artist.id))
        .toSet()
        .toList();

    // Now fetch details for all these artists using fetchSeveralArtists
    return await fetchSeveralArtists(allArtistIds);
  }

  Future<List<Track>?> fetchSeedTracks(
      {required List<String> seedGenres,
      required List<String> seedArtists}) async {
    final tracks = await generateRecommendations(TracksRequest(
        seedGenres: seedGenres.take(5).toList(),
        seedArtists: seedArtists.take(5 - seedGenres.length).toList(),
        limit: 50));

    if (tracks.isEmpty) return null;

    return tracks;
  }

  Future<List<Artist>?> fetchSeveralArtists(List<String> ids) async {
    final data =
        await _getWithCaching("$baseUrl/artists?ids=${ids.take(50).join(',')}");

    if (data == null) return null;

    List<Artist> artists = (data['artists'] as List<dynamic>)
        .map((x) => Artist.fromJson(x))
        .toList();
    for (Artist artist in artists) {
      _cacheManager.set('$baseUrl/artists/${artist.id}', artist,
          ttl: const Duration(minutes: 60));
    }
    return artists;
  }

  Future<User?> fetchUserProfile() async {
    var data = await _getWithCaching('$baseUrl/me', userUnique: true);
    if (data == null) return null;
    return User.fromJson(data);
  }

  Future<PagedResponse<SimplifiedPlaylist>?> fetchUserPlaylists(String userId,
      {int limit = 20, int offset = 0}) async {
    final url = '$baseUrl/users/$userId/playlists?limit=$limit&offset=$offset';

    // Fetch data using the caching method.
    // _getWithCaching now returns the decoded JSON directly, or null.
    final data = await _getWithCaching(url, userUnique: true);

    if (data != null) {
      // Directly work with the returned data, assuming it's already decoded JSON.
      return PagedResponse.fromJson(
          data, (itemJson) => SimplifiedPlaylist.fromJson(itemJson));
    } else {
      // If data is null, it indicates an error or data is not available/cached.
      return null;
    }
  }

  Future<PagedResponse<SimplifiedPlaylist>?> fetchCurrentUserPlaylists(
      {int limit = 50, int offset = 0}) async {
    final url = '$baseUrl/me/playlists?limit=$limit&offset=$offset';

    // Fetch data using the caching method.
    // _getWithCaching now returns the decoded JSON directly, or null.
    final data = await _getWithCaching(url, cachingTime: 2, userUnique: true);

    if (data != null) {
      // Directly work with the returned data, assuming it's already decoded JSON.
      return PagedResponse.fromJson(
          data, (itemJson) => SimplifiedPlaylist.fromJson(itemJson));
    } else {
      // If data is null, it indicates an error or data is not available/cached.
      return null;
    }
  }

  Stream<SimplifiedPlaylist> fetchAllUserPlaylists(String userId) async* {
    int offset = 0;
    bool morePages = true;

    while (morePages) {
      // Fetch the paged response for user playlists.
      final pagedResponse = await fetchUserPlaylists(userId, offset: offset);

      if (pagedResponse != null && pagedResponse.items.isNotEmpty) {
        // Yield each playlist in the current page.
        for (var playlist in pagedResponse.items) {
          yield playlist;
        }
        // Prepare to fetch the next page.
        offset += pagedResponse.limit;
        morePages = pagedResponse.next != null;
      } else {
        // No more pages to fetch.
        morePages = false;
      }
    }
  }

  Future<Playlist?> createPlaylist(String userId, String name,
      {bool isPublic = true,
      bool isCollaborative = false,
      String? description}) async {
    final url = '$baseUrl/users/$userId/playlists';
    final body = jsonEncode({
      'name': name,
      'public': isPublic,
      'collaborative': isCollaborative,
      'description': description == null || description.isEmpty
          ? 'Playlist created by Euterpefy'
          : description,
    });

    final data = await _postWithHandling(url, body);
    if (data != null) {
      return Playlist.fromJson(data);
    } else {
      // Handle errors or return null to indicate an issue.
      return null;
    }
  }

  Future<bool> addTracksToPlaylist(
      String playlistId, List<String> trackIds) async {
    final url = '$baseUrl/playlists/$playlistId/tracks';
    final body = jsonEncode(
        {'uris': trackIds.map((id) => 'spotify:track:$id').toList()});

    final data = await _postWithHandling(url, body);
    return data != null; // True if the operation was successful.
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId) async {
    final url = '$baseUrl/playlists/$playlistId/tracks';
    final data = await _getWithCaching(url);
    if (data != null) {
      List<Track> tracks = [];
      for (var item in data['items']) {
        if (item['track'] != null) {
          tracks.add(Track.fromJson(item['track']));
        }
      }
      return tracks;
    } else {
      // Handle errors or throw an exception based on your preference
      throw Exception('Failed to load playlist tracks');
    }
  }

  Future<List<Category>> fetchBrowseCategories(
      {String? locale, int limit = 20, int offset = 0}) async {
    String url = '$baseUrl/browse/categories';
    Map<String, dynamic> queryParams = {
      if (locale != null) 'locale': locale,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final queryString = Uri(queryParameters: queryParams).query;
    url += '?$queryString';

    List<Category> categories = [];
    dynamic data = await _getWithCaching(url, userUnique: true);
    if (data != null) {
      final items = data['categories']['items'] as List;
      categories.addAll(
          items.map((itemJson) => Category.fromJson(itemJson)).toList());
    }
    return categories;
  }

  Future<List<SimplifiedPlaylist>> fetchAllCategoryPlaylists(
      String categoryId) async {
    List<SimplifiedPlaylist> allPlaylists = [];
    String url =
        '$baseUrl/browse/categories/$categoryId/playlists?limit=20'; // Assuming a default limit of 20 for simplicity

    dynamic data = await _getWithCaching(url, userUnique: true);
    while (data != null) {
      final playlistsJson = data['playlists']['items'] as List;
      List<SimplifiedPlaylist> playlists = playlistsJson
          .map((playlistJson) => SimplifiedPlaylist.fromJson(playlistJson))
          .toList();
      allPlaylists.addAll(playlists);

      String? nextUrl = data['playlists']['next'];
      if (nextUrl != null) {
        data = await _getWithCaching(nextUrl, userUnique: true);
      } else {
        break; // Exit the loop if there is no next page
      }
    }
    return allPlaylists;
  }

  Future<List<SimplifiedPlaylist>> fetchFeaturedPlaylists({
    String? locale,
    int limit = 20,
    int offset = 0,
  }) async {
    Map<String, dynamic> queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (locale != null) 'locale': locale,
    };

    final queryString = Uri(queryParameters: queryParams).query;

    String url = '$baseUrl/browse/featured-playlists?$queryString';

    dynamic data = await _getWithCaching(url, userUnique: true);
    if (data == null) return [];

    return SimplifiedPlaylist.fromJsonList(data['playlists']['items']);
  }

  Future<Album?> fetchAlbum(String albumId) async {
    String url = '$baseUrl/albums/$albumId';
    dynamic data = await _getWithCaching(url);
    if (data == null) return null;
    return Album.fromJson(data);
  }

  Future<List<SimplifiedAlbum>> fetchNewAlbums({
    String? locale,
    int limit = 20,
    int offset = 0,
  }) async {
    Map<String, dynamic> queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (locale != null) 'locale': locale,
    };

    final queryString = Uri(queryParameters: queryParams).query;
    String url = '$baseUrl/browse/new-releases?$queryString';

    dynamic data = await _getWithCaching(url, userUnique: true);
    if (data == null) return [];
    final playlistsJson = data['albums']['items'] as List;
    return playlistsJson.map((json) => SimplifiedAlbum.fromJson(json)).toList();
  }

  Future<List<Artist>> fetchTopArtists({
    String timeRange = 'medium_term',
    int limit = 20,
    int offset = 0,
  }) async {
    final url =
        '$baseUrl/me/top/artists?time_range=$timeRange&limit=$limit&offset=$offset';

    dynamic data = await _getWithCaching(url, userUnique: true);
    if (data == null) return [];
    final items = data['items'] as List;
    return items.map((json) => Artist.fromJson(json)).toList();
  }

  Future<List<Track>> fetchTopTracks({
    String timeRange = 'medium_term',
    int limit = 20,
    int offset = 0,
  }) async {
    final url =
        '$baseUrl/me/top/tracks?time_range=$timeRange&limit=$limit&offset=$offset';

    dynamic data = await _getWithCaching(url, userUnique: true);
    if (data == null) return [];
    final items = data['items'] as List;
    return items.map((json) => Track.fromJson(json)).toList();
  }

  Future<List<Artist>> fetchAllTopArtists(
      {String timeRange = 'medium_term'}) async {
    List<Artist> allArtists = [];
    int limit = 50;
    int offset = 0;
    bool moreAvailable = true;

    while (moreAvailable) {
      final url =
          '$baseUrl/me/top/artists?time_range=$timeRange&limit=$limit&offset=$offset';
      dynamic data = await _getWithCaching(url, userUnique: true);
      if (data != null) {
        final List<dynamic> items = data['items'];
        allArtists.addAll(
            items.map((itemJson) => Artist.fromJson(itemJson)).toList());

        if (items.length < limit) {
          moreAvailable = false;
        } else {
          offset += limit;
        }
      } else {
        moreAvailable = false;
      }
    }

    return allArtists;
  }

  Future<List<Track>> fetchAllTopTracks(
      {String timeRange = 'medium_term'}) async {
    List<Track> allTracks = [];
    int limit = 50;
    int offset = 0;
    bool moreAvailable = true;

    while (moreAvailable) {
      final url =
          '$baseUrl/me/top/tracks?time_range=$timeRange&limit=$limit&offset=$offset';
      dynamic data = await _getWithCaching(url, userUnique: true);

      if (data != null) {
        final List<dynamic> items = data['items'];
        allTracks
            .addAll(items.map((itemJson) => Track.fromJson(itemJson)).toList());

        if (items.length < limit) {
          moreAvailable = false;
        } else {
          offset += limit;
        }
      } else {
        moreAvailable = false;
      }
    }

    return allTracks;
  }

  Future<List<Track>> generateRecommendations(
      TracksRequest tracksRequest) async {
    final queryParams = tracksRequest.toStringJson();
    queryParams.removeWhere(
        (key, value) => value == null || value.toString() == 'null');
    final queryString = Uri(
        queryParameters: queryParams
            .map((key, value) => MapEntry(key, value.toString()))).query;
    final url = '$baseUrl/recommendations?$queryString';
    dynamic data = await _getNoCaching(url);
    if (data != null) {
      final List<dynamic> tracksJson = data['tracks'];
      return tracksJson.map((trackJson) => Track.fromJson(trackJson)).toList();
    } else {
      // If there's no data, return an empty list or handle the error appropriately
      return [];
    }
  }

  Future<void> generateAndEmitPlaylists(
      {int genresBasedPlaylistAmount = 3}) async {
    final topTracks = await fetchTopTracks(limit: 5);

    // Assuming you have a method to generate a playlist from tracks
    await Future.delayed(const Duration(seconds: 1));
    final trackBasedPlaylist = await _generatePlaylistFromTracks(topTracks);
    _playlistStreamController.add(trackBasedPlaylist); // Emit the playlist

    await Future.delayed(const Duration(seconds: 1));
    final topArtists = await fetchTopArtists(limit: 20);
    await Future.delayed(const Duration(seconds: 1));
    final artistBasedPlaylist =
        await _generatePlaylistFromArtists(topArtists.take(5).toList());
    _playlistStreamController.add(artistBasedPlaylist); // Emit the playlist

    // Extract genres from top artists
    Set<String> uniqueGenres = {};
    for (var artist in topArtists) {
      uniqueGenres.addAll(artist.genres);
      if (uniqueGenres.length >= genresBasedPlaylistAmount) {
        break; // Stop after collecting three unique genres
      }
    }
    List<String> topGenres =
        uniqueGenres.take(genresBasedPlaylistAmount).toList();

    for (String genre in topGenres) {
      // Find top artists with the genre
      List<String> genreTopArtistIds = topArtists
          .where((artist) => artist.genres.contains(genre))
          .take(4)
          .map((artist) => artist.id)
          .toList();

      // Generate recommendations for each genre with the top artists as seeds
      List<Track> playlistTracks = await generateRecommendations(TracksRequest(
          seedGenres: [genre],
          seedArtists: genreTopArtistIds,
          limit: 50,
          minPopularity: 40));

      // Create and add the playlist
      _playlistStreamController.add(EuterpefyPlaylist(
        type: "genre_$genre",
        tracks: playlistTracks,
      ));

      await Future.delayed(
          const Duration(seconds: 3)); // Simulate delay for loading
    }
  }

  Future<EuterpefyPlaylist> _generatePlaylistFromTracks(
      List<Track> tracks) async {
    // Seed IDs for recommendations
    final seedTracks = tracks.map((track) => track.id).toList();
    // Generate recommendations
    final recommendations = await generateRecommendations(
        TracksRequest(seedTracks: seedTracks, limit: 50, minPopularity: 40));

    return EuterpefyPlaylist(
      type: "top_tracks",
      tracks: recommendations,
    );
  }

  Future<EuterpefyPlaylist> _generatePlaylistFromArtists(
      List<Artist> artists) async {
    // Seed IDs for recommendations
    final seedArtists = artists.map((e) => e.id).toList();
    // Generate recommendations
    final recommendations = await generateRecommendations(
        TracksRequest(seedArtists: seedArtists, limit: 50, minPopularity: 40));

    return EuterpefyPlaylist(
      type: "top_artists",
      tracks: recommendations,
    );
  }
}

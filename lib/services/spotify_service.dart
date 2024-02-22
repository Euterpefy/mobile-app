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
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class SpotifyService {
  String accessToken;
  String refreshToken;
  DateTime expirationDate;
  final Function onAuthFail;

  SpotifyService({
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
      await refreshAccessToken();
    }
    return accessToken;
  }

  Future<void> refreshAccessToken() async {
    // Implement the refresh logic here, similar to the exchangeCodeForToken function
    // Don't forget to update accessToken, refreshToken, and expirationDate accordingly
    // Also, securely store the new tokens and expiration date
  }

  Future<void> _checkForAuthFailure(Response response) async {
    if (response.statusCode == 401) {
      onAuthFail();
    }
  }

  Future<dynamic> _getWithCaching(String url) async {
    // Check cache first
    if (_cacheManager.has(url)) {
      print("cached");
      return _cacheManager.get(url);
    }

    // Check if we need to respect rate limiting
    if (_rateLimitResetTime != null &&
        DateTime.now().isBefore(_rateLimitResetTime!)) {
      print("rate limited");
      final waitDuration = _rateLimitResetTime!.difference(DateTime.now());
      await Future.delayed(waitDuration);
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    print(response.statusCode);
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
      _cacheManager.set(url, data,
          ttl: const Duration(minutes: 5)); // Adjust TTL as needed
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

  Future<User?> fetchUserProfile() async {
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Create a User object from the data
      var user = User.fromJson(data);
      // Update global user state

      return user;
    }

    return null;
  }

  Future<PagedResponse<SimplifiedPlaylist>?> getUserPlaylists(String userId,
      {int limit = 20, int offset = 0}) async {
    final url =
        'https://api.spotify.com/v1/users/$userId/playlists?limit=$limit&offset=$offset';

    // Fetch data using the caching method.
    // _getWithCaching now returns the decoded JSON directly, or null.
    final data = await _getWithCaching(url);

    if (data != null) {
      // Directly work with the returned data, assuming it's already decoded JSON.
      return PagedResponse.fromJson(
          data, (itemJson) => SimplifiedPlaylist.fromJson(itemJson));
    } else {
      // If data is null, it indicates an error or data is not available/cached.
      return null;
    }
  }

  Stream<SimplifiedPlaylist> getAllUserPlaylists(String userId) async* {
    int offset = 0;
    bool morePages = true;

    while (morePages) {
      // Fetch the paged response for user playlists.
      final pagedResponse = await getUserPlaylists(userId, offset: offset);

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
    final url = 'https://api.spotify.com/v1/users/$userId/playlists';
    final body = jsonEncode({
      'name': name,
      'public': isPublic,
      'collaborative': isCollaborative,
      'description': description,
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
    final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';
    final body = jsonEncode(
        {'uris': trackIds.map((id) => 'spotify:track:$id').toList()});

    final data = await _postWithHandling(url, body);
    return data != null; // True if the operation was successful.
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId) async {
    final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';
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
    String url = 'https://api.spotify.com/v1/browse/categories';
    Map<String, dynamic> queryParams = {
      if (locale != null) 'locale': locale,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final queryString = Uri(queryParameters: queryParams).query;
    url += '?$queryString';

    List<Category> categories = [];
    dynamic data = await _getWithCaching(url);
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
        'https://api.spotify.com/v1/browse/categories/$categoryId/playlists?limit=20'; // Assuming a default limit of 20 for simplicity

    dynamic data = await _getWithCaching(url);
    while (data != null) {
      final playlistsJson = data['playlists']['items'] as List;
      List<SimplifiedPlaylist> playlists = playlistsJson
          .map((playlistJson) => SimplifiedPlaylist.fromJson(playlistJson))
          .toList();
      allPlaylists.addAll(playlists);

      String? nextUrl = data['playlists']['next'];
      if (nextUrl != null) {
        data = await _getWithCaching(nextUrl);
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
    String url =
        'https://api.spotify.com/v1/browse/featured-playlists?$queryString';

    dynamic data = await _getWithCaching(url);
    if (data == null) return [];
    final playlistsJson = data['playlists']['items'] as List;
    return playlistsJson
        .map((json) => SimplifiedPlaylist.fromJson(json))
        .toList();
  }

  Future<Album?> fetchAlbum(String albumId) async {
    String url = 'https://api.spotify.com/v1/albums/$albumId';
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
    String url = 'https://api.spotify.com/v1/browse/new-releases?$queryString';

    dynamic data = await _getWithCaching(url);
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
        'https://api.spotify.com/v1/me/top/artists?time_range=$timeRange&limit=$limit&offset=$offset';

    dynamic data = await _getWithCaching(url);
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
        'https://api.spotify.com/v1/me/top/tracks?time_range=$timeRange&limit=$limit&offset=$offset';

    dynamic data = await _getWithCaching(url);
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
          'https://api.spotify.com/v1/me/top/artists?time_range=$timeRange&limit=$limit&offset=$offset';
      dynamic data = await _getWithCaching(url);
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
          'https://api.spotify.com/v1/me/top/tracks?time_range=$timeRange&limit=$limit&offset=$offset';
      dynamic data = await _getWithCaching(url);

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
    final queryParams = tracksRequest.toJson();
    queryParams.removeWhere(
        (key, value) => value == null || value.toString() == 'null');
    final queryString = Uri(queryParameters: queryParams).query;
    final url = 'https://api.spotify.com/v1/recommendations?$queryString';
    dynamic data = await _getWithCaching(url);

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
    final trackBasedPlaylist = await generatePlaylistFromTracks(topTracks);
    _playlistStreamController.add(trackBasedPlaylist); // Emit the playlist

    await Future.delayed(const Duration(seconds: 1));
    final topArtists = await fetchTopArtists(limit: 20);
    await Future.delayed(const Duration(seconds: 1));
    final artistBasedPlaylist =
        await generatePlaylistFromArtists(topArtists.take(5).toList());
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
        name: "This is $genre",
        description: "A playlist inspired by your interest in $genre.",
        tracks: playlistTracks,
      ));

      await Future.delayed(
          const Duration(seconds: 3)); // Simulate delay for loading
    }
  }

  Future<EuterpefyPlaylist> generatePlaylistFromTracks(
      List<Track> tracks) async {
    // Seed IDs for recommendations
    final seedTracks = tracks.map((track) => track.id).toList();
    // Generate recommendations
    final recommendations = await generateRecommendations(
        TracksRequest(seedTracks: seedTracks, limit: 50, minPopularity: 40));

    return EuterpefyPlaylist(
      name: "Inspired by Your Top Tracks",
      description: "A playlist generated from your top tracks.",
      tracks: recommendations,
    );
  }

  Future<EuterpefyPlaylist> generatePlaylistFromArtists(
      List<Artist> artists) async {
    // Seed IDs for recommendations
    final seedArtists = artists.map((track) => track.id).toList();
    // Generate recommendations
    final recommendations = await generateRecommendations(
        TracksRequest(seedArtists: seedArtists, limit: 50, minPopularity: 40));

    return EuterpefyPlaylist(
      name: "Inspired by Your Top Artists",
      description: "A playlist generated from your top artists.",
      tracks: recommendations,
    );
  }
}

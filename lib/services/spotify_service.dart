import 'dart:convert';
import 'package:euterpefy/models/categories.dart';
import 'package:euterpefy/models/euterpefy_playlist.dart';
import 'package:euterpefy/models/pagination.dart';
import 'package:euterpefy/models/playlist.dart';
import 'package:euterpefy/models/spotify_models.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class SpotifyService {
  final String accessToken;
  final Function onAuthFail;

  SpotifyService({
    required this.accessToken,
    required this.onAuthFail,
  });

  Future<void> _checkForAuthFailure(Response response) async {
    if (response.statusCode == 401) {
      onAuthFail();
    }
  }

  Future<PagedResponse<SimplifiedPlaylist>?> getUserPlaylists(String userId,
      {int limit = 20, int offset = 0}) async {
    final url =
        'https://api.spotify.com/v1/users/$userId/playlists?limit=$limit&offset=$offset';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    _checkForAuthFailure(response);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return PagedResponse.fromJson(
          body, (itemJson) => SimplifiedPlaylist.fromJson(itemJson));
    } else {
      // Handle errors or return null to indicate an issue.
      return null;
    }
  }

  Stream<SimplifiedPlaylist> getAllUserPlaylists(String userId) async* {
    int offset = 0;
    bool morePages = true;

    while (morePages) {
      final response = await getUserPlaylists(userId, offset: offset);

      if (response != null && response.items.isNotEmpty) {
        for (var playlist in response.items) {
          yield playlist;
        }
        offset += response.limit;
        morePages = response.next != null;
      } else {
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

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    _checkForAuthFailure(response);
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
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

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    _checkForAuthFailure(response);
    return response.statusCode == 201;
  }

  // Assuming Track.fromJson is a constructor to parse track data
  Future<List<Track>> fetchPlaylistTracks(String playlistId) async {
    final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    _checkForAuthFailure(response);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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
    // Construct the URL with query parameters for locale, limit, and offset
    String url = 'https://api.spotify.com/v1/browse/categories';
    List<String> queryParams = [];
    if (locale != null) {
      queryParams.add('locale=$locale');
    }
    queryParams.add('limit=$limit');
    queryParams.add('offset=$offset');
    // Join all query parameters with '&' and append to the base URL
    String queryString = queryParams.join('&');
    if (queryParams.isNotEmpty) {
      url += '?$queryString';
    }

    List<Category> categories = [];

    try {
      var nextUrl = url;
      while (nextUrl.isNotEmpty) {
        final response = await http.get(
          Uri.parse(nextUrl),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        _checkForAuthFailure(response);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['categories']['items'] as List;
          categories.addAll(
              items.map((itemJson) => Category.fromJson(itemJson)).toList());

          // Prepare next URL for pagination, if available
          nextUrl = data['categories']['next'] ?? '';
        } else {
          // Handle error or break if status is not 200
          throw Exception('Error fetching categories: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Exception fetching categories: $e');
    }

    return categories;
  }

  Future<List<SimplifiedPlaylist>> fetchAllCategoryPlaylists(
      String categoryId) async {
    List<SimplifiedPlaylist> allPlaylists = [];
    String? nextUrl =
        'https://api.spotify.com/v1/browse/categories/$categoryId/playlists';

    while (nextUrl != null) {
      final response = await http.get(
        Uri.parse(nextUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      _checkForAuthFailure(response);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final playlistsJson = body['playlists']['items'] as List;
        List<SimplifiedPlaylist> playlists = playlistsJson
            .map((playlistJson) => SimplifiedPlaylist.fromJson(playlistJson))
            .toList();
        allPlaylists.addAll(playlists);
        // Check if there's a next page
        nextUrl = body['playlists']['next'];
      } else {
        // Handle errors or throw an exception
        throw Exception('Failed to load category playlists');
      }
    }

    return allPlaylists;
  }

  Future<List<SimplifiedPlaylist>> fetchFeaturedPlaylists({
    String? locale,
    int limit = 20,
    int offset = 0,
  }) async {
    String url = 'https://api.spotify.com/v1/browse/featured-playlists';
    List<String> queryParams = [];
    if (locale != null) {
      queryParams.add('locale=$locale');
    }
    queryParams.add('limit=$limit');
    queryParams.add('offset=$offset');
    String queryString = queryParams.join('&');
    if (queryParams.isNotEmpty) {
      url += '?$queryString';
    }

    List<SimplifiedPlaylist> playlists = [];
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    await _checkForAuthFailure(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final playlistsJson = data['playlists']['items'] as List;
      playlists = playlistsJson
          .map((playlistJson) => SimplifiedPlaylist.fromJson(playlistJson))
          .toList();
    } else {
      // Handle errors or throw an exception
      throw Exception(
          'Failed to load featured playlists: ${response.statusCode}');
    }

    return playlists;
  }

  Future<List<Artist>> fetchTopArtists(
      {String timeRange = 'medium_term',
      int limit = 20,
      int offset = 0}) async {
    final url =
        'https://api.spotify.com/v1/me/top/artists?time_range=$timeRange&limit=$limit&offset=$offset';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((itemJson) => Artist.fromJson(itemJson)).toList();
    } else {
      throw Exception('Failed to fetch top artists');
    }
  }

  Future<List<Track>> fetchTopTracks(
      {String timeRange = 'medium_term',
      int limit = 20,
      int offset = 0}) async {
    final url =
        'https://api.spotify.com/v1/me/top/tracks?time_range=$timeRange&limit=$limit&offset=$offset';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((itemJson) => Track.fromJson(itemJson)).toList();
    } else {
      throw Exception('Failed to fetch top tracks');
    }
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
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        allArtists.addAll(
            items.map((itemJson) => Artist.fromJson(itemJson)).toList());

        if (items.length < limit) {
          moreAvailable = false;
        } else {
          offset += limit;
        }
      } else {
        throw Exception('Failed to fetch all top artists');
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
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        allTracks
            .addAll(items.map((itemJson) => Track.fromJson(itemJson)).toList());

        if (items.length < limit) {
          moreAvailable = false;
        } else {
          offset += limit;
        }
      } else {
        throw Exception('Failed to fetch all top tracks');
      }
    }

    return allTracks;
  }

  Future<List<Track>> generateRecommendations(
      TracksRequest tracksRequest) async {
    final queryParams = tracksRequest.toJson();

    queryParams.removeWhere(
        (key, value) => value == null || value.toString() == 'null');

    // Convert queryParams to a string that can be appended to the URL
    final queryString = Uri(queryParameters: queryParams).query;
    final url = 'https://api.spotify.com/v1/recommendations?$queryString';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    await _checkForAuthFailure(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> tracksJson = data['tracks'];
      List<Track> tracks =
          tracksJson.map((trackJson) => Track.fromJson(trackJson)).toList();
      return tracks;
    } else {
      // Handle errors or throw an exception
      throw Exception(
          'Failed to generate recommendations: ${response.statusCode}');
    }
  }

  Future<List<EuterpefyPlaylist>> generateAppPlaylists() async {
    // Fetch top tracks and artists
    final topTracks = await fetchTopTracks(limit: 5);
    final topArtists = await fetchTopArtists(limit: 5);

    // Seed IDs for recommendations
    final seedTracks = topTracks.map((track) => track.id).toList();
    final seedArtists = topArtists.map((artist) => artist.id).toList();

    // Generate recommendations
    final trackBasedRecommendations = await generateRecommendations(
        TracksRequest(seedTracks: seedTracks, limit: 50));

    final artistBasedRecommendations = await generateRecommendations(
        TracksRequest(seedArtists: seedArtists, limit: 50));
    // Create EuterpefyPlaylist instances
    return [
      EuterpefyPlaylist(
        name: "Inspired by Your Top Tracks",
        description: "A playlist generated from your top tracks.",
        tracks: trackBasedRecommendations,
      ),
      EuterpefyPlaylist(
        name: "Inspired by Your Top Artists",
        description: "A playlist generated from your top artists.",
        tracks: artistBasedRecommendations,
      ),
      // Add other playlists here based on additional concepts you explore
    ];
  }

  Future<List<EuterpefyPlaylist>> generateGenreBasedPlaylists() async {
    final topArtists = await fetchTopArtists(limit: 20);

    // Extract genres from top artists
    Set<String> uniqueGenres = {};
    for (var artist in topArtists) {
      uniqueGenres.addAll(artist.genres);
      if (uniqueGenres.length >= 3) {
        break; // Stop after collecting three unique genres
      }
    }
    List<String> topGenres = uniqueGenres.take(3).toList();

    List<EuterpefyPlaylist> playlists = [];

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
      ));

      // Create and add the playlist
      playlists.add(EuterpefyPlaylist(
        name: "This is $genre",
        description: "A playlist inspired by your interest in $genre.",
        tracks: playlistTracks,
      ));
    }

    return playlists;
  }
}

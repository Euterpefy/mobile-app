import 'dart:convert';

import 'package:euterpefy/models/spotify_models.dart';
import 'package:euterpefy/models/tracks_request.dart';

import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "http://10.0.2.2:8080/api";

  Future<List<String>> fetchGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/seeds/genres'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      // Adjust the parsing to match the structure of your JSON response
      List<String> genres = List<String>.from(body['genres']);
      return genres;
    } else {
      throw Exception('Failed to load genres. Status: ${response.statusCode}');
    }
  }

  Future<List<Artist>> fetchSeedArtists(
      {List<String> selectedGenres = const []}) async {
    // Prepare the headers for a JSON content type request
    final headers = {'Content-Type': 'application/json'};
    // Convert the selected genres list to JSON directly without wrapping in an object
    final String jsonBody = jsonEncode({"genres": selectedGenres});

    // Make a POST request to the backend with the selected genres
    final response = await http.post(
      Uri.parse('$_baseUrl/seeds/artists'),
      headers: headers,
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final body = jsonDecode(response.body);
      final List<dynamic> artistsJson = body['artists'];

      // Map the JSON array to a list of Artist objects
      List<Artist> artists =
          artistsJson.map((json) => Artist.fromJson(json)).toList();

      return artists;
    } else {
      // If the request failed, throw an exception
      throw Exception(
          'Failed to load seed artists. Status: ${response.statusCode}');
    }
  }

  Future<List<Track>> fetchSeedTracks(
      {List<String> selectedGenres = const [],
      List<String> selectedArtists = const []}) async {
    // Prepare the headers for a JSON content type request
    final headers = {'Content-Type': 'application/json'};
    // Convert the selected genres and artists list to JSON directly without wrapping in an object
    final String jsonBody =
        jsonEncode({"genres": selectedGenres, "artists": selectedArtists});

    // Make a POST request to the backend
    final response = await http.post(
      Uri.parse('$_baseUrl/seeds/tracks'),
      headers: headers,
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      final List<dynamic> tracksJson = body['tracks'];
      List<Track> tracks =
          tracksJson.map((json) => Track.fromJson(json)).toList();
      return tracks;
    } else {
      throw Exception(
          'Failed to load seed tracks. Status: ${response.statusCode}');
    }
  }

  Future<List<Track>> fetchRecommendedTracks(
      {required TracksRequest tracksRequest}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recommendation-tracks'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tracksRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      final List<dynamic> tracksJson = body['tracks'];
      List<Track> tracks =
          tracksJson.map((json) => Track.fromJson(json)).toList();
      return tracks;
    } else {
      throw Exception(
          'Failed to load seed tracks. Status: ${response.statusCode}');
    }
  }
}

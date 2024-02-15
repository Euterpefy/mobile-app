import 'package:euterpefy/models/SpotifyModels.dart';
import 'package:euterpefy/models/TracksRequest.dart';
import 'package:euterpefy/services/mock_data/genres.dart';
import 'package:euterpefy/services/mock_data/tracks.dart';

const delay = 0;

class MockApiService {
  Future<List<String>> fetchGenres() async {
    await Future.delayed(const Duration(seconds: delay));
    // Mocking backend response
    return mockGenres; // include all your genres here
  }

  Future<List<Track>> fetchRecommendedTracks(
      {required TracksRequest tracksRequest}) async {
    // Simulate network request waiting time
    await Future.delayed(const Duration(seconds: delay));
    // Mocking backend response based on genre
    // For simplicity, this example does not filter based on genres.
    // In a real app, you would filter or select recommendations based on the genres provided.
    return mockTracks;
  }
}

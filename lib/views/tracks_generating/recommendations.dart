import 'package:euterpefy/models/tracks.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/services/api_service.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';

class RecommendationsScreen extends StatefulWidget {
  final TracksRequest tracksRequest;

  const RecommendationsScreen({
    super.key,
    required this.tracksRequest,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ApiService _apiService = ApiService();

  List<Track> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  void _fetchRecommendations() async {
    List<Track> recommendations = await _apiService.fetchRecommendedTracks(
        tracksRequest: widget.tracksRequest);
    setState(() {
      _recommendations = recommendations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : PlaylistImportView(
            title: "Recommended Tracks",
            tracks: _recommendations,
          );
  }
}

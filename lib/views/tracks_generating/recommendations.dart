import 'package:euterpefy/models/tracks.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  List<Track> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  void _fetchRecommendations() async {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;
    if (spotifyService == null) {
      return;
    }
    List<Track> tracks =
        await spotifyService.generateRecommendations(widget.tracksRequest);
    setState(() {
      _recommendations = tracks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;
    if (spotifyService == null) {
      return const Center(child: Text("You need to log in again."));
    }
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

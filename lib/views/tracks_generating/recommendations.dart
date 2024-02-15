import 'package:euterpefy/models/SpotifyModels.dart';
import 'package:euterpefy/models/TracksRequest.dart';
import 'package:euterpefy/services/api_service.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RecommendationsScreen extends StatefulWidget {
  final TracksRequest tracksRequest;

  const RecommendationsScreen({
    Key? key,
    required this.tracksRequest,
  }) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ApiService _apiService = ApiService();
  List<Track> _recommendations = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTrackId; // ID of the currently playing track

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  void _fetchRecommendations() async {
    // Assuming your API service can handle null values for genres and artists
    List<Track> recommendations = await _apiService.fetchRecommendedTracks(
        tracksRequest: widget.tracksRequest);
    setState(() {
      _recommendations = recommendations;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Recommendations'),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // To center the content vertically in the available space
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    // Provides some space between the indicator and the text
                    Text("Generating your recommendations"),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  var track = _recommendations[index];
                  bool isCurrentTrackPlaying = _playingTrackId == track.id;
                  return ListTile(
                    leading: track.album.images.isNotEmpty
                        ? Image.network(track.album.images.first.url)
                        : null,
                    title: Text(track.name),
                    subtitle: Text(track.artists.map((a) => a.name).join(', ')),
                    trailing: IconButton(
                      icon: Icon(isCurrentTrackPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () => _onTrackButtonPressed(track),
                      color: track.previewUrl == null ? Colors.grey : null,
                    ),
                  );
                },
              ));
  }

  void _onTrackButtonPressed(Track track) {
    if (track.previewUrl != null) {
      if (_playingTrackId == track.id) {
        _stopPreview();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Track preview stopped...'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {

        _playPreview(track.id, track.previewUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing preview...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview is not available for this track'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _playPreview(String trackId, String? url) async {
    if (url != null) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _playingTrackId = trackId;
      });
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _playingTrackId = null;
        });
      });
    }
  }

  void _stopPreview() async {
    await _audioPlayer.stop();
    setState(() {
      _playingTrackId = null;
    });
  }
}

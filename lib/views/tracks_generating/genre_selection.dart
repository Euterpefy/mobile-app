import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/services/api_service.dart';
import 'package:euterpefy/utils/color.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/tracks_generating/artist_selection.dart';
import 'package:euterpefy/views/tracks_generating/recommendations.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class GenreSelectionScreen extends StatefulWidget {
  final int limit;
  final bool advanced;
  final List<String> selectedGenres;

  const GenreSelectionScreen(
      {super.key,
      this.advanced = false,
      this.limit = 5,
      this.selectedGenres = const []});

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  final ApiService _apiService = ApiService();
  List<String> _genres = [];
  final Map<String, bool> _selectedGenres = {};

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  void _fetchGenres() async {
    List<String> genres = await _apiService.fetchGenres();
    setState(() {
      _genres = genres;
      for (var genre in genres) {
        if (widget.selectedGenres.contains(genre)) {
          _selectedGenres[genre] = true;
        } else {
          _selectedGenres[genre] = false;
        }
      }
    });
  }

  bool get _isAnyGenreSelected =>
      _selectedGenres.values.any((selected) => selected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Select Seed Genres"),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Up to 5 seed values may be provided in any combination of genres, artists and tracks.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: _genres
                        .map((genre) => ChoiceChip(
                              selectedColor: yellowSunset,
                              label: Text(genre),
                              selected: _selectedGenres[genre]!,
                              onSelected: (bool selected) {
                                if (selected) {
                                  int selectedCount = _selectedGenres.values
                                      .where((b) => b)
                                      .length;
                                  if (selectedCount < widget.limit) {
                                    setState(() {
                                      _selectedGenres[genre] = selected;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _selectedGenres[genre] = selected;
                                  });
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
                if (_isAnyGenreSelected) const SizedBox(height: 80),
                // Provides space for the fixed buttons
              ],
            ),
          ),
          if (_isAnyGenreSelected)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  color: Colors.white, // Background color for the button bar
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: (!widget.advanced)
                        ? [
                            ElevatedButton(
                              style: elevatedButtonStyle(blue, Colors.white),
                              onPressed: _generateTracks,
                              child: const Text('Generate Tracks'),
                            ),
                            if (getSeedsCount().length < 5)
                              ElevatedButton(
                                style: outlinedButtonStyle(blue),
                                onPressed: _selectArtists,
                                child: const Text('Select Seed Artists'),
                              ),
                          ]
                        : [
                            ElevatedButton.icon(
                              onPressed: _nextAdvanced,
                              label: const Text('Next'),
                              icon: const Icon(Icons.navigate_next),
                            )
                          ],
                  )),
            ),
        ],
      ),
    );
  }

  List<String> getSeedsCount() {
    return _selectedGenres.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void _generateTracks() {
    // Convert selectedGenres map to a list of selected genres
    List<String> selectedGenres = getSeedsCount();

    // Navigate to recommendations screen with selected genres
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecommendationsScreen(
                  tracksRequest: TracksRequest(seedGenres: selectedGenres),
                )));
  }

  void _selectArtists() {
    // Save selected genres and navigate to artist selection screen
    // This could involve passing the selected genres to the next screen or saving them in a state management solution
    List<String> selectedGenres = getSeedsCount();

    // Navigate to artist selection screen (assuming it exists and accepts selectedGenres)
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArtistSelectionScreen(
                selectedGenres: selectedGenres,
                limit: 5 - selectedGenres.length)));
  }

  void _nextAdvanced() {
    // Convert selectedGenres map to a list of selected genres
    List<String> selectedGenres = _selectedGenres.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Pop the screen and pass back the selected genres
    Navigator.pop(context, selectedGenres);
  }
}

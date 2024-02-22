import 'package:euterpefy/models/artists.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/utils/color.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/tracks_generating/artist_selection.dart';
import 'package:euterpefy/views/tracks_generating/genre_selection.dart';
import 'package:euterpefy/views/tracks_generating/recommendations.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:euterpefy/widgets/custom_slider.dart';
import 'package:flutter/material.dart';

class AdvancedGenerationScreen extends StatefulWidget {
  const AdvancedGenerationScreen({super.key});

  @override
  State<AdvancedGenerationScreen> createState() =>
      _AdvancedGenerationScreenState();
}

class _AdvancedGenerationScreenState extends State<AdvancedGenerationScreen> {
  List<String> selectedGenres = [];
  List<Artist> selectedArtists = [];
  List<String> selectedTracks = [];
  RangeValues _popularityRange = const RangeValues(0, 100);
  RangeValues _danceAbilityRange = const RangeValues(0, 1);
  RangeValues _energyRange = const RangeValues(0, 1);
  RangeValues _valanceRange = const RangeValues(0, 1);
  RangeValues _loudnessRange = const RangeValues(-60, 0);

  @override
  Widget build(BuildContext context) {
    int totalSeeds =
        selectedGenres.length + selectedArtists.length + selectedTracks.length;

    return Scaffold(
        appBar: customAppBar(context, "Advanced Recommender"),
        body: Stack(children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Genres',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  alignment: WrapAlignment.center,
                  children: List<Widget>.generate(
                    selectedGenres.length,
                    (int index) {
                      return Chip(
                        label: Text(selectedGenres[index]),
                        onDeleted: () {
                          setState(() {
                            selectedGenres.removeAt(index);
                          });
                        },
                      );
                    },
                  )..add(
                      totalSeeds < 5
                          ? (selectedGenres.isEmpty
                              ? OutlinedButton.icon(
                                  onPressed: () =>
                                      _navigateAndDisplayGenreSelection(
                                          context),
                                  label: const Text('Select'),
                                  icon: const Icon(Icons.add),
                                  style: outlinedButtonStyle(blue),
                                )
                              : IconButton.filledTonal(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _navigateAndDisplayGenreSelection(
                                          context),
                                ))
                          : Container(),
                    ),
                ),
                if (totalSeeds != 0 && totalSeeds <= 5)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Artist',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    alignment: WrapAlignment.center,
                    children: List<Widget>.generate(
                      selectedArtists.length,
                      (int index) {
                        return Chip(
                            label: Text(selectedArtists[index].name),
                            onDeleted: () {
                              setState(() {
                                selectedArtists.removeAt(index);
                              });
                            },
                            avatar: selectedArtists[index].images.isNotEmpty
                                ? Image.network(
                                    selectedArtists[index].images.first.url)
                                : null);
                      },
                    )..add(
                        (totalSeeds != 0 && totalSeeds < 5)
                            ? (selectedArtists.isEmpty
                                ? ElevatedButton.icon(
                                    onPressed: () =>
                                        _navigateAndDisplayArtistSelection(
                                            context),
                                    label: const Text('Select'),
                                    icon: const Icon(Icons.add),
                                  )
                                : IconButton.filledTonal(
                                    icon: const Icon(Icons.add),
                                    onPressed: () =>
                                        _navigateAndDisplayArtistSelection(
                                            context),
                                  ))
                            : Container(),
                      )),
                CustomRangeSlider(
                  label: 'Popularity',
                  rangeValues: _popularityRange,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _popularityRange = values;
                    });
                  },
                  decimalPlaces: 0,
                  // Since popularity is an integer
                  description:
                      "The popularity of the track. The value will be between 0 and 100, with 100 being the most popular.\n\nThe popularity of a track is a value between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.",
                ),
                CustomRangeSlider(
                  label: 'Dance-ability',
                  rangeValues: _danceAbilityRange,
                  min: 0,
                  max: 1,
                  divisions: 1000,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _danceAbilityRange = values;
                    });
                  },
                  decimalPlaces: 3,
                  description:
                      "Dance-ability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity.",
                ),
                CustomRangeSlider(
                  label: 'Energy',
                  rangeValues: _energyRange,
                  min: 0,
                  max: 1,
                  divisions: 1000,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _energyRange = values;
                    });
                  },
                  decimalPlaces: 3,
                  description:
                      "Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.",
                ),
                CustomRangeSlider(
                  label: 'Valance',
                  rangeValues: _valanceRange,
                  min: 0,
                  max: 1,
                  divisions: 1000,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _valanceRange = values;
                    });
                  },
                  decimalPlaces: 3,
                  description:
                      "A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).",
                ),
                CustomRangeSlider(
                  label: 'Loudness',
                  rangeValues: _loudnessRange,
                  min: -60,
                  max: 0,
                  divisions: 1000,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _loudnessRange = values;
                    });
                  },
                  decimalPlaces: 3,
                  description:
                      "The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db.",
                ),
              ],
            ),
          ),
          if (totalSeeds > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  color: Colors.white, // Background color for the button bar
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _generateRecommendations,
                        child: const Text('Generate Tracks'),
                      ),
                    ],
                  )),
            ),
        ]));
  }

  void _navigateAndDisplayGenreSelection(BuildContext context) async {
    int totalSeeds = selectedArtists.length + selectedTracks.length;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GenreSelectionScreen(
              advanced: true,
              selectedGenres: selectedGenres,
              limit: 5 - totalSeeds)),
    );

    // Assuming result is a List<String> of selected genres
    if (result != null) {
      setState(() {
        selectedGenres = result;
      });
    }
  }

  void _navigateAndDisplayArtistSelection(BuildContext context) async {
    int totalSeeds = selectedGenres.length + selectedTracks.length;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArtistSelectionScreen(
              advanced: true,
              selectedGenres: selectedGenres,
              selectedArtists: selectedArtists,
              limit: 5 - totalSeeds)),
    );

    // Assuming result is a List<String> of selected genres
    if (result != null) {
      setState(() {
        selectedArtists = result;
      });
    }
  }

  void _generateRecommendations() {
    Navigator.pop(context);
    // Navigate to recommendations screen with selected genres and artists
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecommendationsScreen(
                tracksRequest: TracksRequest(
                    seedGenres: selectedGenres,
                    seedArtists:
                        selectedArtists.map((artist) => artist.id).toList()))));
  }
}

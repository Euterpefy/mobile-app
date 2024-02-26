import 'package:euterpefy/models/artists.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/tracks_generating/advanced_criterias.dart';
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
  List<Criteria> _criteriaList = [];

  @override
  void initState() {
    super.initState();
    _criteriaList = trackRequestCriterias;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var bottomPadding = MediaQuery.of(context).padding.bottom;

    int totalSeeds =
        selectedGenres.length + selectedArtists.length + selectedTracks.length;
    return Scaffold(
        appBar: customAppBar(context, "Advanced Recommender"),
        body: Stack(children: [
          SingleChildScrollView(
            child: Center(
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                                ? ElevatedButton.icon(
                                    onPressed: () =>
                                        _navigateAndDisplayGenreSelection(
                                            context),
                                    label: const Text('Select'),
                                    icon: const Icon(Icons.add),
                                    style: elevatedButtonStyle(
                                        theme.colorScheme.secondary,
                                        theme.colorScheme.onSecondary),
                                  )
                                : IconButton(
                                    style: elevatedButtonStyle(
                                        theme.colorScheme.secondary,
                                        theme.colorScheme.onSecondary),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
                  Column(
                    children: _criteriaList.map((criteria) {
                      return CustomCriteriaSlider(
                        criteria: criteria,
                        onChanged: (values) {
                          setState(() {
                            criteria.values = values;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (totalSeeds > 0)
                    const SizedBox(
                      height: 100,
                    )
                ],
              ),
            ),
          ),
          if (totalSeeds > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  // color: theme.colorScheme.primaryContainer,
                  padding: EdgeInsets.fromLTRB(
                      8, 8, 8, bottomPadding == 0 ? 8 : bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _generateRecommendations,
                        style: elevatedButtonStyle(theme.colorScheme.primary,
                            theme.colorScheme.onPrimary),
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
    TracksRequest request = TracksRequest.fromJson(
        criteriaListToTrackRequestJson(
            selectedGenres,
            selectedArtists.map((e) => e.id).toList(),
            selectedTracks,
            _criteriaList));
    request.limit = 100;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RecommendationsScreen(tracksRequest: request)));
  }
}

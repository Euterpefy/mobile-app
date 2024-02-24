import 'package:euterpefy/models/artists.dart';
import 'package:euterpefy/models/tracks_request.dart';
import 'package:euterpefy/utils/color.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/tracks_generating/recommendations.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistSelectionScreen extends StatefulWidget {
  final List<String> selectedGenres;
  final List<Artist> selectedArtists;
  final int limit;
  final bool advanced;

  const ArtistSelectionScreen(
      {super.key,
      this.advanced = false,
      this.limit = 5,
      this.selectedGenres = const [],
      this.selectedArtists = const []});

  @override
  State<ArtistSelectionScreen> createState() => _ArtistSelectionScreenState();
}

class _ArtistSelectionScreenState extends State<ArtistSelectionScreen> {
  List<Artist> _artists = [];
  final Map<String, bool> _selectedArtists = {};
  DateTime _lastFetchTime = DateTime.now().subtract(const Duration(minutes: 1));
  bool _cooldownActive = false;

  bool get _isAnyArtistSelected =>
      _selectedArtists.values.any((selected) => selected);

  @override
  void initState() {
    super.initState();
    _initializeSelectedArtists();
    _fetchRecommendArtists();
  }

  void _initializeSelectedArtists() {
    // Initialize _selectedArtists with widget.selectedArtists
    for (var artist in widget.selectedArtists) {
      _selectedArtists[artist.id] = true;
    }
  }

  Future<void> _fetchRecommendArtists({bool merge = true}) async {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;

    DateTime now = DateTime.now();
    if (now.difference(_lastFetchTime).inSeconds >= 60 || !merge) {
      List<Artist> newArtists = await spotifyService!
              .fetchSeedArtists(seedGenres: widget.selectedGenres) ??
          [];
      setState(() {
        if (merge) {
          // Merge new artists with existing ones, avoiding duplicates
          final allArtists = {..._artists, ...newArtists};
          _artists = allArtists.toList();
        } else {
          _artists = newArtists;
        }
        _lastFetchTime = now;
        _cooldownActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> actionButtons = _buildActionButtons(theme);
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: customAppBar(context, "Select Seed Artists"),
      body: Stack(children: [
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
                  children: _artists
                      .map((artist) => ChoiceChip(
                            showCheckmark: false,
                            selectedColor: yellowSunset,
                            labelStyle: TextStyle(
                              color: (_selectedArtists[artist.id] ?? false)
                                  ? Colors.black
                                  : theme.colorScheme.onBackground,
                            ),
                            label: Text(artist.name),
                            selected: _selectedArtists[artist.id] ?? false,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  // Limit selection to 5 artists
                                  int selectedCount = _selectedArtists.values
                                      .where((b) => b)
                                      .length;
                                  if (selectedCount < widget.limit) {
                                    _selectedArtists[artist.id] = selected;
                                  }
                                } else {
                                  _selectedArtists[artist.id] = selected;
                                }
                              });
                            },
                            avatar: artist.images.isNotEmpty
                                ? Image.network(artist.images.first.url)
                                : null,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 80),
              // Provides space for the fixed buttons
            ],
          ),
        ),
        if (_isAnyArtistSelected)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: theme.colorScheme.primaryContainer,
              padding: EdgeInsets.fromLTRB(
                  8, 8, 8, bottomPadding == 0 ? 8 : bottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actionButtons,
              ),
            ),
          ),
      ]),
    );
  }

  List<String> getSelectedArtists() {
    List<String> selectedArtists = _selectedArtists.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    return selectedArtists;
  }

  int getSelectedSeedsCount() {
    return getSelectedArtists().length + widget.selectedGenres.length;
  }

  void _generateRecommendations() {
    List<String> selectedArtists = getSelectedArtists();

    Navigator.pop(context);
    Navigator.pop(context);
    // Navigate to recommendations screen with selected genres and artists
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecommendationsScreen(
                  tracksRequest: TracksRequest(
                      seedGenres: widget.selectedGenres,
                      seedArtists: selectedArtists),
                )));
  }

  void _nextAdvanced() {
    // Convert selectedGenres map to a list of selected genres
    List<String> selectedArtistIds = _selectedArtists.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    List<Artist> selectedArtist = _artists
        .where((artist) => selectedArtistIds.contains(artist.id))
        .toList();

    // Pop the screen and pass back the selected genres
    Navigator.pop(context, selectedArtist);
  }

  List<Widget> _buildActionButtons(ThemeData theme) {
    if (widget.advanced) {
      return [
        ElevatedButton.icon(
          onPressed: _nextAdvanced,
          label: const Text('Next'),
          icon: const Icon(Icons.navigate_next),
          style: elevatedButtonStyle(
              theme.colorScheme.primary, theme.colorScheme.onPrimary),
        ),
      ];
    } else {
      List<Widget> buttons = [
        ElevatedButton(
          onPressed: _generateRecommendations,
          style: elevatedButtonStyle(
              theme.colorScheme.primary, theme.colorScheme.onPrimary),
          child: const Text('Generate Tracks'),
        ),
      ];

      if (getSelectedSeedsCount() < 5) {
        buttons.add(
          ElevatedButton(
            onPressed: () {
              // Your logic for selecting seed tracks
            },
            style: elevatedButtonStyle(
                theme.colorScheme.secondary, theme.colorScheme.onSecondary),
            child: const Text('Select Seed Tracks'),
          ),
        );
      }

      return buttons;
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed:
          _cooldownActive ? _showCooldownSnackbar : _fetchRecommendArtists,
      tooltip: 'Load new artists',
      child: const Icon(Icons.refresh),
    );
  }

  void _showCooldownSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading new artists on cooldown...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

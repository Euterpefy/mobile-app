// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:euterpefy/extensions/string.dart';
import 'package:euterpefy/models/euterpefy_playlist.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EuterpefyPlaylistSection extends StatefulWidget {
  const EuterpefyPlaylistSection({
    super.key,
  });

  @override
  State<EuterpefyPlaylistSection> createState() =>
      _EuterpefyPlaylistSectionState();
}

class _EuterpefyPlaylistSectionState extends State<EuterpefyPlaylistSection> {
  StreamSubscription<EuterpefyPlaylist>? _playlistSubscription;

  // a map (key: lists of playlists)
  final Map<String, List<EuterpefyPlaylist>> _playlistsMap = {};
  List<String> generatedGenres = [];

  Future<void> loadPlaylists() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // check for generated playlists by genres
    // "genres" will be a lists of genre(s) generated
    List<String> genres =
        prefs.getStringList('${appContext.user!.id}/generated_genres') ?? [];
    setState(() {
      generatedGenres = genres;
    });
    // Assuming you have a list of topics
    List<String> topics = [
          'top_tracks',
          'top_artists',
        ] +
        genres;

    for (String topic in topics) {
      String? playlistData =
          prefs.getString('${appContext.user!.id}/generated_playlists_$topic');
      if (playlistData != null) {
        List<EuterpefyPlaylist> playlists = json
            .decode(playlistData)
            .map<EuterpefyPlaylist>((json) => EuterpefyPlaylist.fromJson(json))
            .toList();
        setState(() {
          _playlistsMap[topic] = playlists;
        });
      }
    }

    // Check the time since last update for each topic and decide whether to update
    checkAndUpdatePlaylistsIfNeeded();
  }

  Future<void> checkAndUpdatePlaylistsIfNeeded() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateString =
        prefs.getString('${appContext.user!.id}/last_playlist_generated');
    DateTime lastUpdate = lastUpdateString != null
        ? DateTime.parse(lastUpdateString)
        : DateTime.now().subtract(const Duration(days: 1));

    if (DateTime.now().difference(lastUpdate).inMinutes > 10 ||
        _playlistsMap.isEmpty) {
      final appContext = Provider.of<AppContext>(context, listen: false);
      final spotifyService = appContext.spotifyService;
      if (spotifyService != null) {
        initPlaylists();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  void initPlaylists() {
    final spotifyService =
        Provider.of<AppContext>(context, listen: false).spotifyService;
    _playlistSubscription?.cancel();

    if (spotifyService != null) {
      spotifyService.generateAndEmitPlaylists();
      _playlistSubscription = spotifyService.playlistStream.listen(
        (playlist) {
          String topic = playlist.type;

          if (!_playlistsMap.containsKey(topic)) {
            setState(() {
              _playlistsMap[topic] = [];
            });
          }
          setState(() {
            _playlistsMap[topic] = [playlist] + (_playlistsMap[topic] ?? []);
          });

          storeUpdatedPlaylists();
        },
        onError: (error) {
          print("Error receiving playlist: $error");
        },
      );
    } else {
      // Spotify service is null, indicating the user is not logged in
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotifyService = Provider.of<AppContext>(context).spotifyService;

    // Check if the user is logged in by checking if spotifyService is not null
    if (spotifyService == null) {
      // User is not logged in, show login prompt
      return Column(
        children: [
          const SectionTitle(title: "For you"),
          Text(
            "Log in to browse playlists generated just of you.",
            style: Theme.of(context).textTheme.labelLarge,
          )
        ],
      );
    }

    return Column(
      children: _playlistsMap.entries
          .map((entry) => _buildSection(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildSection(String title, List<EuterpefyPlaylist> playlists) {
    return Section(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: topicToSectionTitle(title)),
        SizedBox(
          height: 280, // Adjust based on your content
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              var playlist = playlists[index];
              return _buildPlaylistCard(playlist, index);
            },
          ),
        ),
      ],
    ));
  }

  Widget _buildPlaylistCard(EuterpefyPlaylist playlist, int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistImportView(
                title: 'Mix ${index + 1}',
                tracks: playlist.tracks,
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlaylistCover(playlist),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mix ${index + 1}',
                      style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      playlist.tracks
                          .map((e) => e.artists.map((e) => e.name))
                          .fold(
                              [],
                              (previousValue, element) =>
                                  previousValue + element.toList())
                          .toSet()
                          .take(15)
                          .join(', '),
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: theme.colorScheme.secondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCover(EuterpefyPlaylist playlist) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: playlist.tracks
                .take(2)
                .map((t) => t.album.images.first.url)
                .toList()
                .map((url) => Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Ensures the image is square
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ))
                .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: playlist.tracks
                .skip(2)
                .take(2)
                .map((t) => t.album.images.first.url)
                .toList()
                .map((url) => Expanded(
                      child: AspectRatio(
                        aspectRatio: 1, // Ensures the image is square
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  // Utility method to convert JSON data to a list of playlists
  List<EuterpefyPlaylist> convertJsonToPlaylists(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((json) => EuterpefyPlaylist.fromJson(json)).toList();
  }

  Future<void> storeUpdatedPlaylists() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    _playlistsMap.forEach((topic, playlists) {
      prefs.setString('${appContext.user!.id}/generated_playlists_$topic',
          jsonEncode(playlists.take(10).map((p) => p.toJson()).toList()));

      if (topic.startsWith("genre_")) {
        if (!generatedGenres.contains(topic)) {
          setState(() {
            generatedGenres = generatedGenres + [topic];
          });
          prefs.setStringList(
              "${appContext.user!.id}/generated_genres", generatedGenres);
        }
      }
    });
    // Update the last generated timestamp
    prefs.setString('${appContext.user!.id}/last_playlist_generated',
        DateTime.now().toIso8601String());
  }
}

String topicToSectionTitle(String topic) {
  switch (topic) {
    case 'top_tracks':
      return "From your top tracks";
    case 'top_artists':
      return "From your top artists";

    default:
      if (topic.startsWith("genre_")) {
        return "${topic.split("_")[1].split(" ").map((e) => e.capitalize()).join(" ")} for you";
      }
      return "For you";
  }
}

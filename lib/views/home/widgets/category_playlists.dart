// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/models/playlists.dart';
import 'package:euterpefy/services/spotify_service.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:euterpefy/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CategoryPlaylistsScreen extends StatelessWidget {
  final String categoryName;
  final String categoryId;

  const CategoryPlaylistsScreen(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Access the AppContext to check for the token
    final appContext = Provider.of<AppContext>(context);

    final spotifyService = appContext.spotifyService;

    return Scaffold(
      appBar: customAppBar(context, 'Playlists: $categoryName'),
      body: spotifyService != null
          ? _buildPlaylistsView(spotifyService, categoryId)
          : _buildLoginPrompt(),
    );
  }

  Widget _buildPlaylistsView(
      SpotifyService? spotifyService, String categoryId) {
    return Column(
      children: [
        FutureBuilder<List<SimplifiedPlaylist>>(
          future: spotifyService?.fetchAllCategoryPlaylists(categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final playlists = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return Slidable(
                      key: Key(playlists[index].id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            flex: 2,
                            onPressed: (_) =>
                                _onImportPressed(playlists[index].id),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.playlist_add,
                            label: 'Import',
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () async {
                          // Assuming 'fetchPlaylistTracks' is a method in SpotifyService
                          try {
                            final tracks = await Provider.of<AppContext>(
                                    context,
                                    listen: false)
                                .spotifyService
                                ?.fetchPlaylistTracks(playlist.id);

                            if (tracks != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistImportView(
                                    title: playlist.name,
                                    tracks: tracks,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Failed to load playlist details.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: ListTile(
                          title: Text(playlist.name),
                          subtitle: Text('Tracks: ${playlist.tracks.total}'),
                          leading: playlist.images.isNotEmpty
                              ? Image.network(playlist.images.first.url)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return const Text("Error fetching playlists");
            }
            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Please log in to view playlists.',
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement login functionality
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  void _onImportPressed(String playlistId) {}
}

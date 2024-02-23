// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/models/playlists.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:euterpefy/views/playlist/playlist_importing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturedPlaylistsSection extends StatefulWidget {
  final String? locale;
  final String sectionTitle;

  const FeaturedPlaylistsSection({
    super.key,
    this.locale,
    this.sectionTitle = "Featured Playlists",
  });

  @override
  State<FeaturedPlaylistsSection> createState() =>
      _FeaturedPlaylistsSectionState();
}

class _FeaturedPlaylistsSectionState extends State<FeaturedPlaylistsSection> {
  final List<SimplifiedPlaylist> _playlists = [];
  bool _isFetching = false;
  bool _hasMore = true; // Initially, assume there's more data to load
  int _offset = 0; // Keep track of loaded data offset
  final int _limit = 20; // Number of items to load per page
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPlaylists();
  }

  void _fetchPlaylists() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    if (appContext.spotifyService == null) return;
    if (_isFetching || !_hasMore) return;

    setState(() {
      _isFetching = true;
    });

    final newPlaylists =
        await appContext.spotifyService?.fetchFeaturedPlaylists(
      locale: widget.locale,
      limit: _limit,
      offset: _offset,
    );

    if (newPlaylists == null || newPlaylists.isEmpty) {
      setState(() {
        _hasMore = false;
      });
    } else {
      _offset += newPlaylists.length; // Update offset for the next fetch
      _playlists.addAll(newPlaylists);
    }

    setState(() {
      _isFetching = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isFetching &&
        _hasMore) {
      _fetchPlaylists(); // Load more data
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
          SectionTitle(title: widget.sectionTitle),
          Text(
            "Log in to browse featured playlists.",
            style: Theme.of(context).textTheme.labelLarge,
          )
        ],
      );
    }

    // User is logged in, proceed with showing the playlists or loading indicator
    return Column(
      children: [
        SectionTitle(title: widget.sectionTitle),
        _playlists.isEmpty && !_isFetching
            ? const Center(child: CircularProgressIndicator())
            : _buildPlaylistsListView(),
        // Add a condition to handle the empty state when there are no playlists and fetching is done
        if (_playlists.isEmpty && !_isFetching && !_hasMore)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No featured playlists available.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildPlaylistsListView() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _playlists.length +
            (_hasMore
                ? 1
                : 0), // Add extra space for loading indicator if more data is available
        itemBuilder: (context, index) {
          if (index >= _playlists.length) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator at the end
          }
          final playlist = _playlists[index];
          return _buildPlaylistCard(playlist);
        },
      ),
    );
  }

  Widget _buildPlaylistCard(SimplifiedPlaylist playlist) {
    return GestureDetector(
      onTap: () async {
        // Assuming 'fetchPlaylistTracks' is a method in SpotifyService
        try {
          final tracks = await Provider.of<AppContext>(context, listen: false)
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
              const SnackBar(content: Text('Failed to load playlist details.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 160),
        margin: const EdgeInsets.only(left: 4.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                playlist.images.first.url,
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150, // Set maximum width for the text
                ),
                child: Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Allow text wrapping up to two lines
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

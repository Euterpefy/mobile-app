// ignore_for_file: use_build_context_synchronously

import 'package:euterpefy/extensions/string.dart';
import 'package:euterpefy/models/albums.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/album/album_view.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewAlbumsSection extends StatefulWidget {
  final String? locale;
  final String sectionTitle;

  const NewAlbumsSection({
    super.key,
    this.locale,
    this.sectionTitle = "New albums and singles",
  });

  @override
  State<NewAlbumsSection> createState() => _NewAlbumsSectionState();
}

class _NewAlbumsSectionState extends State<NewAlbumsSection> {
  final List<SimplifiedAlbum> _albums = [];
  bool _isFetching = false;
  bool _hasMore = true; // Initially, assume there's more data to load
  int _offset = 0; // Keep track of loaded data offset
  final int _limit = 20; // Number of items to load per page
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
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
    _fetchAlbums();
  }

  void _fetchAlbums() async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    if (appContext.spotifyService == null) return;
    if (_isFetching || !_hasMore) return;

    setState(() {
      _isFetching = true;
    });

    final newAlbums = await appContext.spotifyService?.fetchNewAlbums(
      locale: widget.locale,
      limit: _limit,
      offset: _offset,
    );

    if (newAlbums == null || newAlbums.isEmpty) {
      _hasMore = false;
    } else {
      _offset += newAlbums.length; // Update offset for the next fetch
      _albums.addAll(newAlbums);
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
      _fetchAlbums(); // Load more data
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotifyService = Provider.of<AppContext>(context).spotifyService;

    // Check if the user is logged in by checking if spotifyService is not null
    if (spotifyService == null) {
      // User is not logged in, show login prompt
      return Column(
        children: [
          SectionTitle(title: widget.sectionTitle),
          Text(
            "Log in to browse featured albums.",
            style: theme.textTheme.labelLarge,
          )
        ],
      );
    }

    // User is logged in, proceed with showing the albums or loading indicator
    return Column(
      children: [
        SectionTitle(title: widget.sectionTitle),
        _albums.isEmpty && _isFetching
            ? const CircularProgressIndicator() // Show a loading indicator if the initial fetch is ongoing
            : _buildAlbumsListView(),
        // Add a condition to handle the empty state when there are no albums and fetching is done
        if (_albums.isEmpty && !_isFetching && !_hasMore)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No featured albums available.",
              style: theme.textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildAlbumsListView() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _albums.length +
            (_hasMore
                ? 1
                : 0), // Add extra space for loading indicator if more data is available
        itemBuilder: (context, index) {
          if (index >= _albums.length) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator at the end
          }
          final album = _albums[index];
          return _buildAlbumCard(album);
        },
      ),
    );
  }

  Widget _buildAlbumCard(SimplifiedAlbum album) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        // Assuming 'fetchAlbumTracks' is a method in SpotifyService
        try {
          final fullAlbum =
              await Provider.of<AppContext>(context, listen: false)
                  .spotifyService
                  ?.fetchAlbum(album.id);

          if (fullAlbum != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumView(
                  album: fullAlbum,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load album details.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 155),
        margin: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                album.images.first.url,
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    "${album.albumType.capitalize()} • ${album.artists.map((e) => e.name).join(", ")}",
                    style: theme.textTheme.labelMedium!
                        .copyWith(color: theme.colorScheme.secondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

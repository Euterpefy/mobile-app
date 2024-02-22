import 'package:euterpefy/views/home/widgets/browse_section.dart';
import 'package:euterpefy/views/home/widgets/featured_playlists.dart';
import 'package:euterpefy/views/home/widgets/new_albums.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:flutter/material.dart';

class SpotifyBrowsingTab extends StatefulWidget {
  const SpotifyBrowsingTab({
    super.key,
  });

  @override
  State<SpotifyBrowsingTab> createState() => _SpotifyBrowsingTabState();
}

class _SpotifyBrowsingTabState extends State<SpotifyBrowsingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Need to call super.build
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Section(child: BrowseSection()),
            Section(child: FeaturedPlaylistsSection()),
            Section(child: NewAlbumsSection()),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

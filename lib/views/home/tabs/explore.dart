import 'package:euterpefy/views/home/widgets/euterperfy_playlists.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:flutter/material.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({
    super.key,
  });

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
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
            Section(child: EuterpefyPlaylistSection()),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

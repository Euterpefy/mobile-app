import 'package:euterpefy/models/spotify_models.dart';
import 'package:euterpefy/models/tracks.dart';
import 'package:euterpefy/models/user.dart';

class CreatePlaylistRequest {
  final NewPlaylist newPlaylist;
  final List<String> trackIds;

  CreatePlaylistRequest({
    required this.newPlaylist,
    required this.trackIds,
  });

  Map<String, dynamic> toJson() => {
        'new_playlist': newPlaylist.toJson(),
        'track_ids': trackIds,
      };
}

class NewPlaylist {
  final String name;
  final bool public;
  final bool collaborative;
  final String? description;

  NewPlaylist({
    required this.name,
    required this.public,
    required this.collaborative,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'public': public,
        'collaborative': collaborative,
        'description': description,
      };
}

class Playlist {
  final bool collaborative;
  final String? description;
  final ExternalUrls externalUrls;
  final Followers followers;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final SimplifiedUser owner;
  final bool public;
  final String snapshotId;
  final Tracks tracks;

  Playlist({
    required this.collaborative,
    this.description,
    required this.externalUrls,
    required this.followers,
    required this.id,
    required this.images,
    required this.name,
    required this.owner,
    required this.public,
    required this.snapshotId,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      collaborative: json['collaborative'],
      description: json['description'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      followers: Followers.fromJson(json['followers']),
      id: json['id'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      name: json['name'],
      owner: SimplifiedUser.fromJson(json['owner']),
      public: json['public'],
      snapshotId: json['snapshot_id'],
      tracks: Tracks.fromJson(json['tracks']),
    );
  }
}

class Tracks {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<PlaylistTrack> items;
  Tracks({
    required this.limit,
    this.next,
    required this.offset,
    this.previous,
    required this.href,
    required this.total,
    required this.items,
  });

  factory Tracks.fromJson(Map<String, dynamic> json) {
    return Tracks(
      href: json['href'] as String,
      total: json['total'] as int,
      items: List<PlaylistTrack>.from(
          json['items'].map((x) => PlaylistTrack.fromJson(x))),
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
}

class PlaylistTrack {
  final String addedAt;
  final SimplifiedUser addedBy;
  final bool isLocal;
  final Track track;

  PlaylistTrack({
    required this.addedAt,
    required this.addedBy,
    required this.isLocal,
    required this.track,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      addedAt: json['added_at'],
      addedBy: SimplifiedUser.fromJson(json['added_by']),
      isLocal: json['is_local'],
      track: Track.fromJson(json['track']),
    );
  }
}

class SimplifiedPlaylistTracks {
  final String href;
  final int total;

  SimplifiedPlaylistTracks({
    required this.href,
    required this.total,
  });

  factory SimplifiedPlaylistTracks.fromJson(Map<String, dynamic> json) {
    return SimplifiedPlaylistTracks(
      href: json['href'] as String,
      total: json['total'] as int,
    );
  }
}

class SimplifiedPlaylist {
  final bool collaborative;
  final String? description;
  final ExternalUrls externalUrls;
  final String href;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final SimplifiedUser owner;
  final bool? public;
  final String snapshotId;
  final SimplifiedPlaylistTracks tracks;
  final String type;
  final String uri;

  SimplifiedPlaylist({
    required this.collaborative,
    this.description,
    required this.externalUrls,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.owner,
    this.public,
    required this.snapshotId,
    required this.tracks,
    required this.type,
    required this.uri,
  });

  factory SimplifiedPlaylist.fromJson(Map<String, dynamic> json) {
    return SimplifiedPlaylist(
      collaborative: json['collaborative'],
      description: json['description'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      href: json['href'],
      id: json['id'],
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      name: json['name'],
      owner: SimplifiedUser.fromJson(json['owner']),
      public: json['public'],
      snapshotId: json['snapshot_id'],
      tracks: SimplifiedPlaylistTracks.fromJson(json['tracks']),
      type: json['type'],
      uri: json['uri'],
    );
  }

  static List<SimplifiedPlaylist> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SimplifiedPlaylist.fromJson(json)).toList();
  }
}

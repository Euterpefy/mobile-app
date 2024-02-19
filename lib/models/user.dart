import 'package:euterpefy/models/spotify_models.dart';

class User {
  final String country;
  final String? displayName;
  final String? email;
  final ExplicitContent? explicitContent;
  final ExternalUrls externalUrls;
  final Followers followers;
  final String href;
  final String id;
  final List<SpotifyImage>? images;
  final String? product;
  final String type;
  final String uri;

  User({
    required this.country,
    this.displayName,
    required this.email,
    required this.explicitContent,
    required this.externalUrls,
    required this.followers,
    required this.href,
    required this.id,
    this.images,
    this.product,
    required this.type,
    required this.uri,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      country: json['country'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      explicitContent: json['explicit_content'] != null
          ? ExplicitContent.fromJson(
              json['explicit_content'] as Map<String, dynamic>)
          : null,
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      followers: Followers.fromJson(json['followers']),
      href: json['href'] as String,
      id: json['id'] as String,
      images: List<SpotifyImage>.from(
          json['images'].map((x) => SpotifyImage.fromJson(x))),
      product: json['product'] as String?,
      type: json['type'] as String,
      uri: json['uri'] as String,
    );
  }
}

class SimplifiedUser {
  final ExternalUrls externalUrls;
  final Followers? followers;
  final String href;
  final String id;
  final String type;
  final String uri;
  final String? displayName;

  SimplifiedUser({
    required this.externalUrls,
    this.followers,
    required this.href,
    required this.id,
    required this.type,
    required this.uri,
    this.displayName,
  });

  factory SimplifiedUser.fromJson(Map<String, dynamic> json) {
    return SimplifiedUser(
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      followers: json['followers'] != null
          ? Followers.fromJson(json['followers'])
          : null,
      href: json['href'] as String,
      id: json['id'] as String,
      type: json['type'] as String,
      uri: json['uri'] as String,
      displayName: json['display_name'] as String?,
    );
  }
}

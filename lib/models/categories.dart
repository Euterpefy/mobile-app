import 'package:euterpefy/models/pagination.dart';
import 'package:euterpefy/models/spotify_models.dart';

class Category {
  final String href;
  final List<SpotifyImage> icons;
  final String id;
  final String name;

  Category({
    required this.href,
    required this.icons,
    required this.id,
    required this.name,
  });

  factory Category.fromJson(
    Map<String, dynamic> json,
  ) {
    return Category(
      href: json['href'] as String,
      icons: List<SpotifyImage>.from(
          json['icons'].map((x) => SpotifyImage.fromJson(x))),
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class Categories {
  final PagedResponse<Category> categories;

  Categories({required this.categories});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
        categories: PagedResponse<Category>.fromJson(
            json, (itemJson) => Category.fromJson(itemJson)));
  }
}

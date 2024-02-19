import 'package:euterpefy/models/categories.dart';
import 'package:euterpefy/utils/providers/app_context.dart';
import 'package:euterpefy/views/home/widgets/category_playlists.dart';
import 'package:euterpefy/views/home/widgets/section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BrowseSection extends StatefulWidget {
  final String? locale;
  final String sectionTitle;

  const BrowseSection({
    super.key,
    this.locale,
    this.sectionTitle = "Browse By Topics",
  });

  @override
  State<BrowseSection> createState() => _BrowseSectionState();
}

class _BrowseSectionState extends State<BrowseSection> {
  Future<List<Category>>? _categoriesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCategoriesFuture();
  }

  void _updateCategoriesFuture() {
    final appContext = Provider.of<AppContext>(context);
    _categoriesFuture =
        appContext.spotifyService?.fetchBrowseCategories(locale: widget.locale);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: widget.sectionTitle),
        if (_categoriesFuture != null)
          FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final categories = snapshot.data!;
                return _buildCategoriesListView(categories);
              } else if (snapshot.hasError) {
                return Text("Error fetching categories: ${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          )
        else
          Text(
            "Log in to browse playlists.",
            style: Theme.of(context).textTheme.labelLarge,
          ),
      ],
    );
  }

  Widget _buildCategoriesListView(List<Category> categories) {
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPlaylistsScreen(
                categoryName: category.name, categoryId: category.id),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 150),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  category.icons.first.url,
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

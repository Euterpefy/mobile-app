// lib/views/home/home.dart
import 'package:euterpefy/utils/styles/buttons.dart';
import 'package:euterpefy/views/home/tabs/account.dart';
import 'package:euterpefy/views/home/tabs/explore.dart';
import 'package:euterpefy/views/home/tabs/browse.dart';
import 'package:euterpefy/views/tracks_generating/advanced_generator.dart';
import 'package:euterpefy/views/tracks_generating/genre_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              itemBuilder: (_, index) {
                switch (index) {
                  case 0:
                    return const SpotifyBrowsingTab();
                  case 1:
                    return const ExploreTab();
                  case 2:
                    return const AccountTab();
                  default:
                    return const SpotifyBrowsingTab(); // Fallback
                }
              },
              itemCount: 3, // Total number of tabs
            ),
            if (_selectedIndex != 2) // Only show for Explore and Home tabs
              Align(
                alignment: Alignment.bottomCenter,
                child: generateButtons(theme),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            backgroundColor: theme.colorScheme.primaryContainer,
            padding: const EdgeInsets.all(8.0),
            gap: 8.0,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            activeColor: Theme.of(context).colorScheme.onPrimary,
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _pageController
                  .jumpToPage(index); // Use PageController to switch pages
            },
            tabs: const [
              GButton(icon: Icons.search, text: 'Browse'),
              GButton(icon: Icons.explore, text: 'Explore'),
              GButton(icon: Icons.person, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget generateButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GenreSelectionScreen()),
              );
            },
            style: elevatedButtonStyle(theme.colorScheme.inversePrimary,
                theme.colorScheme.inverseSurface),
            child: const Text('Quick Generating'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdvancedGenerationScreen()),
              );
            },
            style: elevatedButtonStyle(theme.colorScheme.primaryContainer,
                theme.colorScheme.onPrimaryContainer),
            child: const Text('Advanced Generating'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 23),
          ),
          const SizedBox(
            width: 8,
          ),
          SvgPicture.asset(
            'assets/images/spotify_icon.svg',
            height: 20.0,
            width: 20.0,
          ),
          const Spacer()
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final Widget child;

  const Section({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: child);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpotifyLogo extends StatelessWidget {
  final double size;

  const SpotifyLogo({super.key, this.size = 24});
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/spotify_icon.svg',
      height: size,
      width: size,
    );
  }
}

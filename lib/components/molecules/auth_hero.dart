import 'package:flutter/material.dart';

/// Displays the logo + title combo used across auth-related screens.
class AuthHero extends StatelessWidget {
  final bool isDesktop;
  final String title;
  final double desktopLogoSize;
  final Size mobileLogoSize;

  const AuthHero({
    super.key,
    required this.isDesktop,
    required this.title,
    this.desktopLogoSize = 260,
    this.mobileLogoSize = const Size(350, 175),
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall;
    final logo = Semantics(
      image: true,
      label: 'Logo do app',
      child: Image.asset(
        'assets/logo.png',
        width: isDesktop ? desktopLogoSize : mobileLogoSize.width,
        height: isDesktop ? desktopLogoSize : mobileLogoSize.height,
      ),
    );

    final titleWidget = Text(title, style: textStyle);

    if (isDesktop) {
      return Row(children: [logo, const SizedBox(width: 8), titleWidget]);
    }

    return Column(children: [logo, const SizedBox(height: 8), titleWidget]);
  }
}

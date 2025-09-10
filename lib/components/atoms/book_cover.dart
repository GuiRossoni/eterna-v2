import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String imageAsset;
  final String heroTag;
  final double width;
  final double? height;
  final String semanticLabel;

  const BookCover({
    super.key,
    required this.imageAsset,
    required this.heroTag,
    this.width = 110,
    this.height,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Semantics(
        label: semanticLabel,
        image: true,
        child: Container(
          width: width,
          height: height ?? width * 1.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imageAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

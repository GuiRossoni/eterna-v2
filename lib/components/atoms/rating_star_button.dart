import 'package:flutter/material.dart';

class RatingStarButton extends StatelessWidget {
  final bool filled;
  final VoidCallback onPressed;
  final int position;

  const RatingStarButton({
    super.key,
    required this.filled,
    required this.onPressed,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.star, color: filled ? Colors.amber : Colors.grey[400]),
      tooltip: 'Avaliar com $position estrelas',
      onPressed: onPressed,
    );
  }
}

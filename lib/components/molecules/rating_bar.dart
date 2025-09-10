import 'package:flutter/material.dart';
import '../atoms/rating_star_button.dart';

class RatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChange;
  const RatingBar({super.key, required this.rating, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final pos = index + 1;
        return RatingStarButton(
          position: pos,
          filled: pos <= rating,
          onPressed: () => onChange(pos),
        );
      }),
    );
  }
}

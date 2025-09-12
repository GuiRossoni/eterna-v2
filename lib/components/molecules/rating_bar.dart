import 'package:flutter/material.dart';
import '../atoms/rating_star_button.dart';

class RatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChange;
  const RatingBar({super.key, required this.rating, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Avaliação: $rating de 5',
      value: '$rating',
      child: Row(
        children: List.generate(5, (index) {
          final pos = index + 1;
          return RatingStarButton(
            position: pos,
            filled: pos <= rating,
            onPressed: () => onChange(pos),
          );
        }),
      ),
    );
  }
}

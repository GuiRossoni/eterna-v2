import 'package:flutter/material.dart';

class BookCoverSkeleton extends StatelessWidget {
  final double width;
  final double? height;
  const BookCoverSkeleton({super.key, this.width = 110, this.height});

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.45;
    return Semantics(
      label: 'Capa carregando',
      child: Container(
        width: width,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade300, Colors.grey.shade200],
          ),
        ),
      ),
    );
  }
}

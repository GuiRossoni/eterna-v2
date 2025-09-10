import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final String user;
  final int stars;
  final String text;
  const CommentItem({
    super.key,
    required this.user,
    required this.stars,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 16,
                  color: i < stars ? Colors.amber : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(text),
      ),
    );
  }
}

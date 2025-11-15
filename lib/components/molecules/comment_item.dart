import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final String user;
  final int? stars;
  final String text;
  final DateTime? createdAt;

  const CommentItem({
    super.key,
    required this.user,
    required this.text,
    this.stars,
    this.createdAt,
  });

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(createdAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (formattedDate != null)
                  Text(
                    formattedDate,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
            if (stars != null) ...[
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  final isFilled = stars != null && i < stars!;
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: isFilled ? Colors.amber : Colors.grey[400],
                  );
                }),
              ),
            ],
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}

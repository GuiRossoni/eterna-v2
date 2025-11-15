class WorkReview {
  final String user;
  final String text;
  final int? rating;
  final DateTime? createdAt;
  final String? authorId;

  const WorkReview({
    required this.user,
    required this.text,
    this.rating,
    this.createdAt,
    this.authorId,
  });
}

class RatingSummary {
  final double? average;
  final int count;
  final Map<int, int> distribution;

  const RatingSummary({
    this.average,
    this.count = 0,
    this.distribution = const <int, int>{},
  });

  factory RatingSummary.fromReviews(List<WorkReview> reviews) {
    if (reviews.isEmpty) {
      return const RatingSummary();
    }
    int total = 0;
    double sum = 0;
    final dist = <int, int>{};
    for (final review in reviews) {
      final score = review.rating;
      if (score == null) continue;
      total++;
      sum += score;
      dist.update(score, (value) => value + 1, ifAbsent: () => 1);
    }
    return RatingSummary(
      average: total == 0 ? null : sum / total,
      count: total,
      distribution: Map.unmodifiable(dist),
    );
  }
}

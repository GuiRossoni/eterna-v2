class BookModel {
  final String title;
  final String? imageAsset;
  final String? imageUrl;
  final String synopsis;
  final List<String> authors;
  final String? workKey;
  final int? year;
  final double? price; // preço opcional

  const BookModel.asset({
    required this.title,
    required this.imageAsset,
    required this.synopsis,
    this.authors = const [],
    this.workKey,
    this.year,
    this.price,
  }) : imageUrl = null;

  const BookModel.network({
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    this.authors = const [],
    this.workKey,
    this.year,
    this.price,
  }) : imageAsset = null;

  bool get isNetwork => imageUrl != null && imageUrl!.isNotEmpty;
}

class BookModel {
  final String title;
  final String? imageAsset;
  final String? imageUrl;
  final String synopsis;

  const BookModel.asset({
    required this.title,
    required this.imageAsset,
    required this.synopsis,
  }) : imageUrl = null;

  const BookModel.network({
    required this.title,
    required this.imageUrl,
    required this.synopsis,
  }) : imageAsset = null;

  bool get isNetwork => imageUrl != null && imageUrl!.isNotEmpty;
}

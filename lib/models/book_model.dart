class BookModel {
  final String title;
  final String? imageAsset;
  final String? imageUrl;
  final String synopsis;
  final List<String> authors;
  final String? workKey;
  final int? year;
  final double? price; // preço opcional
  // Campos de anúncio (quando originado de Firestore listings)
  final String? listingId;
  final String? listingType; // sale | swap | donation
  final String? exchangeWanted; // livro desejado na troca
  final String? userId; // dono do anúncio
  final String? userDisplayName; // nome visível do usuário
  final DateTime? createdAt; // data de criação do anúncio

  const BookModel.asset({
    required this.title,
    required this.imageAsset,
    required this.synopsis,
    this.authors = const [],
    this.workKey,
    this.year,
    this.price,
    this.listingId,
    this.listingType,
    this.exchangeWanted,
    this.userId,
    this.userDisplayName,
    this.createdAt,
  }) : imageUrl = null;

  const BookModel.network({
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    this.authors = const [],
    this.workKey,
    this.year,
    this.price,
    this.listingId,
    this.listingType,
    this.exchangeWanted,
    this.userId,
    this.userDisplayName,
    this.createdAt,
  }) : imageAsset = null;

  bool get isNetwork => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isListing => listingId != null;

  String timeAgo() {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays >= 1) return 'há ${diff.inDays}d';
    if (diff.inHours >= 1) return 'há ${diff.inHours}h';
    if (diff.inMinutes >= 1) return 'há ${diff.inMinutes}m';
    return 'agora';
  }
}

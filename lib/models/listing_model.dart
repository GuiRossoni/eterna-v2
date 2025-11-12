enum ListingType { sale, swap, donation }

class ListingModel {
  final String id;
  final String userId;
  final String? userDisplayName;
  final String title;
  final List<String> authors;
  final String synopsis;
  final String? imageUrl;
  final ListingType type;
  final double? price; // required if sale
  final String? exchangeWanted; // required if swap
  final DateTime? createdAt;

  const ListingModel({
    required this.id,
    required this.userId,
    this.userDisplayName,
    required this.title,
    required this.authors,
    required this.synopsis,
    this.imageUrl,
    required this.type,
    this.price,
    this.exchangeWanted,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userDisplayName': userDisplayName,
    'title': title,
    'authors': authors,
    'synopsis': synopsis,
    'imageUrl': imageUrl,
    'type': type.name,
    'price': price,
    'exchangeWanted': exchangeWanted,
    'createdAt': createdAt?.toIso8601String(),
  };

  static ListingModel fromMap(String id, Map<String, dynamic> map) =>
      ListingModel(
        id: id,
        userId: (map['userId'] ?? '').toString(),
        userDisplayName: (map['userDisplayName'] as String?),
        title: (map['title'] ?? '').toString(),
        authors:
            (map['authors'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        synopsis: (map['synopsis'] ?? '').toString(),
        imageUrl:
            (map['imageUrl'] as String?)?.isNotEmpty == true
                ? map['imageUrl'] as String
                : null,
        type: _parseType(map['type']?.toString()),
        price: map['price'] is num ? (map['price'] as num).toDouble() : null,
        exchangeWanted:
            (map['exchangeWanted'] as String?)?.isNotEmpty == true
                ? map['exchangeWanted'] as String
                : null,
        createdAt: _parseDate(map['createdAt']),
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // Firestore Timestamp
    final timestampType = value.runtimeType.toString();
    if (timestampType == 'Timestamp') {
      try {
        // ignore: avoid_dynamic_calls
        return (value as dynamic).toDate() as DateTime?;
      } catch (_) {
        return null;
      }
    }
    if (value is Map &&
        value['seconds'] is int &&
        value['nanoseconds'] is int) {
      final seconds = value['seconds'] as int;
      final nanos = value['nanoseconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanos ~/ 1000000,
      );
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static ListingType _parseType(String? s) {
    switch (s) {
      case 'sale':
        return ListingType.sale;
      case 'swap':
        return ListingType.swap;
      case 'donation':
        return ListingType.donation;
      default:
        return ListingType.donation;
    }
  }
}

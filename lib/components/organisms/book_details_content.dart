import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../molecules/comment_item.dart';
import 'book_header.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/book_service.dart';
import '../../presentation/state/providers.dart';

class BookDetailsContent extends ConsumerStatefulWidget {
  final String heroTag;
  final String? imageAsset;
  final String? imageUrl;
  final String title;
  final String synopsis;
  final String? workKey;
  final String reviewKey;
  final List<String> authors;
  final int? year;
  final String? listingType;
  final String? listingId;
  final String? exchangeWanted;
  final double? price;
  final String? ownerName;
  final String? ownerId;

  const BookDetailsContent({
    super.key,
    required this.heroTag,
    this.imageAsset,
    this.imageUrl,
    required this.title,
    required this.synopsis,
    this.workKey,
    required this.reviewKey,
    this.authors = const [],
    this.year,
    this.listingType,
    this.listingId,
    this.exchangeWanted,
    this.price,
    this.ownerName,
    this.ownerId,
  });

  @override
  ConsumerState<BookDetailsContent> createState() => _BookDetailsContentState();
}

class _BookDetailsContentState extends ConsumerState<BookDetailsContent> {
  // Campos locais para submissão de avaliações
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _userRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<Widget> _buildAverageStars(double? average) {
    final safeValue = average ?? 0;
    return List.generate(5, (index) {
      final position = index + 1;
      IconData icon;
      if (safeValue >= position) {
        icon = Icons.star;
      } else if ((safeValue + 0.5) >= position) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: Colors.amber, size: 20);
    });
  }

  Widget _buildNoRatingsMessage(BuildContext context) => Text(
    'Ainda não há avaliações registradas para este livro.',
    style: Theme.of(context).textTheme.bodyMedium,
  );

  Widget _buildNoCommentsMessage(BuildContext context) => Text(
    'Ainda não há comentários para este livro.',
    style: Theme.of(context).textTheme.bodyMedium,
  );

  void _logReviewFallback(Object err, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('Fallback de avaliações/comentários acionado: $err');
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }
  }

  Widget? _buildListingInfoCard(BuildContext context) {
    final listingType = widget.listingType?.toLowerCase().trim() ?? '';
    final price = widget.price;
    final owner = (widget.ownerName ?? '').trim();
    final desiredTrade = (widget.exchangeWanted ?? '').trim();
    final showDesiredTrade = listingType == 'swap' && desiredTrade.isNotEmpty;
    final infoRows = <Widget>[];
    if (owner.isNotEmpty) {
      infoRows.add(
        _infoRow(
          context,
          icon: Icons.person_outline,
          label: 'Anunciante',
          value: owner,
        ),
      );
    }
    switch (listingType) {
      case 'sale':
        final priceLabel =
            price != null
                ? 'R\$ ${price.toStringAsFixed(2)}'
                : 'Disponível para venda';
        infoRows.add(
          _infoRow(
            context,
            icon: Icons.sell_outlined,
            label: 'Modalidade',
            value: price != null ? 'Venda por $priceLabel' : priceLabel,
          ),
        );
        break;
      case 'donation':
        infoRows.add(
          _infoRow(
            context,
            icon: Icons.volunteer_activism_outlined,
            label: 'Modalidade',
            value: 'Doação',
          ),
        );
        break;
      case 'swap':
        infoRows.add(
          _infoRow(
            context,
            icon: Icons.swap_horiz,
            label: 'Modalidade',
            value: 'Troca',
          ),
        );
        break;
    }
    if (showDesiredTrade) {
      infoRows.add(
        _infoRow(
          context,
          icon: Icons.bookmark_add_outlined,
          label: 'Deseja trocar por',
          value: desiredTrade,
        ),
      );
    }
    final addToCart = _buildAddToCartControl(context, listingType);
    if (infoRows.isEmpty && addToCart == null) return null;
    final separatedRows = <Widget>[];
    for (final row in infoRows) {
      if (separatedRows.isNotEmpty) {
        separatedRows.add(const SizedBox(height: 6));
      }
      separatedRows.add(row);
    }
    if (addToCart != null) {
      if (separatedRows.isNotEmpty) {
        separatedRows.add(const SizedBox(height: 12));
      }
      separatedRows.add(addToCart);
    }
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do anúncio',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...separatedRows,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              children: [TextSpan(text: value, style: textTheme.bodyMedium)],
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildAddToCartControl(BuildContext context, String listingType) {
    if (!_shouldShowAddToCart(listingType)) return null;
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar ao carrinho'),
        onPressed: () => _handleAddListingToCart(context),
      ),
    );
  }

  bool _shouldShowAddToCart(String listingType) {
    if (listingType != 'sale') return false;
    if (widget.price == null) return false;
    final listingId = widget.listingId?.trim();
    if (listingId == null || listingId.isEmpty) return false;
    final ownerId = widget.ownerId?.trim();
    final currentUserId = ref.read(listingServiceProvider).currentUserId;
    if (ownerId != null && ownerId.isNotEmpty && currentUserId != null) {
      if (ownerId == currentUserId) return false;
    }
    return true;
  }

  void _handleAddListingToCart(BuildContext context) {
    final cart = ref.read(cartStateProvider.notifier);
    final book = _toCartBookModel();
    cart.add(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adicionado ao carrinho: ${widget.title}')),
    );
  }

  BookModel _toCartBookModel() {
    if ((widget.imageUrl ?? '').isNotEmpty) {
      return BookModel.network(
        title: widget.title,
        imageUrl: widget.imageUrl!,
        synopsis: widget.synopsis,
        authors: widget.authors,
        workKey: widget.workKey,
        year: widget.year,
        price: widget.price,
        listingId: widget.listingId,
        listingType: widget.listingType,
        exchangeWanted: widget.exchangeWanted,
        userId: widget.ownerId,
        userDisplayName: widget.ownerName,
      );
    }
    if ((widget.imageAsset ?? '').isNotEmpty) {
      return BookModel.asset(
        title: widget.title,
        imageAsset: widget.imageAsset!,
        synopsis: widget.synopsis,
        authors: widget.authors,
        workKey: widget.workKey,
        year: widget.year,
        price: widget.price,
        listingId: widget.listingId,
        listingType: widget.listingType,
        exchangeWanted: widget.exchangeWanted,
        userId: widget.ownerId,
        userDisplayName: widget.ownerName,
      );
    }
    return BookModel.network(
      title: widget.title,
      imageUrl: '',
      synopsis: widget.synopsis,
      authors: widget.authors,
      workKey: widget.workKey,
      year: widget.year,
      price: widget.price,
      listingId: widget.listingId,
      listingType: widget.listingType,
      exchangeWanted: widget.exchangeWanted,
      userId: widget.ownerId,
      userDisplayName: widget.ownerName,
    );
  }

  Widget _buildStarRatingField(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall;
    final helperStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sua avaliação (1 a 5)', style: labelStyle),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: List.generate(5, (index) {
            final score = index + 1;
            final isFilled = score <= _userRating;
            return IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
              tooltip: '$score estrela${score > 1 ? 's' : ''}',
              onPressed:
                  _isSubmitting
                      ? null
                      : () => setState(() => _userRating = score),
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Colors.amber : Colors.grey,
                size: 28,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _userRating == 0
              ? 'Toque nas estrelas para escolher.'
              : 'Você selecionou $_userRating de 5.',
          style: helperStyle,
        ),
      ],
    );
  }

  Future<void> _handleSubmitReview(
    BuildContext context,
    String reviewKey,
  ) async {
    if (reviewKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não é possível avaliar este item.')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final comment = _commentController.text.trim();
    if (_userRating == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecione uma avaliação em estrelas.')),
      );
      return;
    }
    if (comment.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Digite um comentário antes de enviar.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final svc = ref.read(reviewServiceProvider);
    try {
      final typedName = _nameController.text.trim();
      await svc.submitReview(
        reviewKey: reviewKey,
        text: comment,
        rating: _userRating,
        overrideName: typedName.isEmpty ? null : typedName,
      );
      if (!mounted) return;
      setState(() {
        _userRating = 0;
        _commentController.clear();
        _nameController.clear();
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Comentário enviado!')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Falha ao enviar comentário: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workKey = widget.workKey ?? '';
    final reviewKey = widget.reviewKey;
    final listingInfoCard = _buildListingInfoCard(context);
    final detailsAsync =
        workKey.isEmpty
            ? const AsyncValue<WorkDetails?>.data(null)
            : ref.watch(workDetailsProvider(workKey));
    final ratingAsync =
        reviewKey.isEmpty
            ? const AsyncValue<RatingSummary?>.data(null)
            : ref.watch(workRatingProvider(reviewKey));
    final reviewsAsync =
        reviewKey.isEmpty
            ? const AsyncValue<List<WorkReview>>.data(<WorkReview>[])
            : ref.watch(workReviewsProvider(reviewKey));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookHeader(
          heroTag: widget.heroTag,
          imageAsset: widget.imageAsset,
          imageUrl: widget.imageUrl,
          synopsis: widget.synopsis,
        ),
        const SizedBox(height: 20),
        // Metadados: autores e ano
        if (widget.authors.isNotEmpty || widget.year != null) ...[
          Builder(
            builder: (context) {
              final availableWidth = (MediaQuery.of(context).size.width - 32)
                  .clamp(120.0, double.infinity);
              Widget metaTile(IconData icon, String text) {
                return SizedBox(
                  width: availableWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(text, softWrap: true)),
                    ],
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (widget.authors.isNotEmpty)
                    metaTile(Icons.person, widget.authors.join(', ')),
                  if (widget.year != null)
                    metaTile(Icons.calendar_today, '${widget.year}'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        if (listingInfoCard != null) ...[
          listingInfoCard,
          const SizedBox(height: 16),
        ],
        // Descrição e assuntos via Open Library
        Builder(
          builder: (context) {
            return detailsAsync.when(
              data: (details) {
                if (details == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details.description != null &&
                        details.description!.isNotEmpty) ...[
                      Text(
                        'Descrição',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(details.description!),
                      const SizedBox(height: 12),
                    ],
                    if (details.subjects.isNotEmpty) ...[
                      Text(
                        'Assuntos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            details.subjects
                                .take(12)
                                .map((s) => Chip(label: Text(s)))
                                .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              error:
                  (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Não foi possível carregar mais detalhes.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                    ),
                  ),
            );
          },
        ),
        const SizedBox(height: 12),
        ratingAsync.when(
          data: (summary) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avaliações',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (summary == null || summary.count == 0)
                  _buildNoRatingsMessage(context)
                else ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(children: _buildAverageStars(summary.average)),
                      Text(
                        summary.average != null
                            ? '${summary.average!.toStringAsFixed(1)} / 5'
                            : 'Sem média',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('(${summary.count} avaliações)'),
                    ],
                  ),
                ],
              ],
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (err, stack) {
            _logReviewFallback(err, stack);
            return _buildNoRatingsMessage(context);
          },
        ),
        const SizedBox(height: 20),
        Text('Comentários', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return _buildNoCommentsMessage(context);
            }
            return Column(
              children:
                  reviews
                      .map(
                        (review) => CommentItem(
                          user: review.user,
                          stars: review.rating,
                          text: review.text,
                          createdAt: review.createdAt,
                        ),
                      )
                      .toList(),
            );
          },
          loading:
              () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          error: (err, stack) {
            _logReviewFallback(err, stack);
            return _buildNoCommentsMessage(context);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Compartilhe sua avaliação',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildStarRatingField(context),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Seu nome (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Comentário',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'Enviando...' : 'Enviar comentário'),
            onPressed:
                _isSubmitting
                    ? null
                    : () => _handleSubmitReview(context, reviewKey),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/favorite_service.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  final _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.restaurant.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.restaurant.id);
    } else {
      await _favoriteService.addFavorite(widget.restaurant.id);
    }
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String get _arrondissement {
    final address = widget.restaurant.address;
    final match = RegExp(r'750(\d{2})').firstMatch(address);
    return match != null ? '750${match.group(1)!}' : '';
  }

  String get _cuisine => widget.restaurant.cuisine.isNotEmpty ? widget.restaurant.cuisine.first : '';
  String get _price => widget.restaurant.priceRange.isNotEmpty ? widget.restaurant.priceRange.first : '';

  @override
  Widget build(BuildContext context) {
    final photos = widget.restaurant.photoUrls.take(2).toList();

    return AspectRatio(
      aspectRatio: 3 / 2, // Pour un look équilibré
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEBE5DC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos + favori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_capitalize(_arrondissement)} | ${_capitalize(_cuisine)} | $_price',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              widget.restaurant.trueName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'CustomSerif',
              ),
            ),
            const SizedBox(height: 8),
            // Images qui prennent tout l'espace restant
            Expanded(
              child: Row(
                children: List.generate(2, (index) {
                  final url = photos.length > index ? photos[index] : null;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: index == 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade300,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: url != null
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 1.5),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

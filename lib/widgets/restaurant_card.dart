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
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.restaurant.id);
    } else {
      await _favoriteService.addFavorite(widget.restaurant.id);
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.restaurant.photoUrls;

    return AspectRatio(
      aspectRatio: 2 / 2.5,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${widget.restaurant.arrondissement} • ${widget.restaurant.typeCuisine} • ${widget.restaurant.prix}',
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.restaurant.vraiNom,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CustomSerif',
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (photos.isNotEmpty)
                    ? PageView.builder(
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            photos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 1.5),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

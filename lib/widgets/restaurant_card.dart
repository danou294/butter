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

  String get _cuisine =>
      widget.restaurant.cuisine.isNotEmpty ? widget.restaurant.cuisine.first : '';

  String get _price =>
      widget.restaurant.priceRange.isNotEmpty ? widget.restaurant.priceRange.first : '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = cardWidth * 1.5;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1EFEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopInfo(),
                const SizedBox(height: 2),
                _buildNameImage(),
                const SizedBox(height: 6),
                Expanded(child: _buildPhotoRow()),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Image.asset(
                  _isFavorite
                      ? 'assets/navigation-tools/favoris_black.png'
                      : 'assets/navigation-tools/favoris.png',
                  width: 26,
                  height: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 32),
      child: Text(
        '${_capitalize(_arrondissement)} | ${_capitalize(_cuisine)} | $_price',
        style: const TextStyle(
          fontFamily: 'InriaSans',
          fontSize: 10,
          color: Color(0xFF535353),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNameImage() {
    final firstImage = widget.restaurant.photoUrls.isNotEmpty
        ? widget.restaurant.photoUrls[0]
        : null;

    return firstImage != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.network(
              firstImage,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(height: 28),
            ),
          )
        : const SizedBox(height: 28);
  }

  Widget _buildPhotoRow() {
    final images = widget.restaurant.photoUrls.skip(1).take(2).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Row(
        children: List.generate(2, (index) {
          final url = images.length > index ? images[index] : null;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == 1 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.grey.shade300,
              ),
              clipBehavior: Clip.antiAlias,
              child: url != null
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
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
    );
  }
}

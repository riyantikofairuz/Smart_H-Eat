import 'dart:async';

import 'package:flutter/material.dart';

import '../models/banner_item.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.banners.length <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextIndex = (_currentIndex + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      // Restart auto-slide timer to ensure consistent 4-second delay after manual swipe
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AspectRatio(
        aspectRatio: 698 / 265,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAB2F00), Color(0xFFFA842E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.banners.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return Image.asset(
                      banner.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFECE5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Color(0xFFAB2F00),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  banner.title,
                                  style: const TextStyle(
                                    color: Color(0xFFAB2F00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Dots indicator: overlay at the bottom inside the banner
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.banners.length, (index) {
                          final isActive = index == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFFA842E)
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

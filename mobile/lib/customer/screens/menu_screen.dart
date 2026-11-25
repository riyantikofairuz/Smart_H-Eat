import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/product_item.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/smart_heat_header.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'Semua';

  List<ProductItem> get _filteredProducts {
    if (_selectedCategory == 'Semua') {
      return DummyData.products;
    }
    return DummyData.products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  void _handleCartTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CartScreen()));
  }

  void _handleProductSelect(ProductItem product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          children: [
            // Persistent Header (always visible during vertical scroll)
            SmartHeatHeader(onCartTap: _handleCartTap),

            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Promotional Banner Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                      child: BannerCarousel(banners: DummyData.banners),
                    ),
                  ),

                  // 2. Food Category Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: CategoryFilter(
                        categories: DummyData.categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ),

                  // 3. Product Grid (2 columns)
                  if (displayedProducts.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.05,
                              crossAxisSpacing: 26,
                              mainAxisSpacing: 18,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = displayedProducts[index];
                          return ProductCard(
                            product: product,
                            onSelect: () => _handleProductSelect(product),
                          );
                        }, childCount: displayedProducts.length),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Tidak ada produk untuk kategori ini.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                  // Bottom padding for aesthetic whitespace
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final int price;
  final String category;
  final String imagePath;
  final String? description;

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    this.description,
  });

  String get formattedPrice {
    // Format price to Indonesian Rupiah standard format (e.g. Rp 28.000)
    final priceStr = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      buffer.write(priceStr[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }
}

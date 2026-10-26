/// Model untuk satu topping pilihan (data dummy lokal).
class ToppingItem {
  final String id;
  final String name;
  final int price; // harga tambahan per porsi, dalam Rupiah (integer)

  const ToppingItem({
    required this.id,
    required this.name,
    required this.price,
  });

  String get formattedPrice {
    final priceStr = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      buffer.write(priceStr[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '+Rp ${buffer.toString().split('').reversed.join('')}';
  }

  /// Daftar topping dummy yang tersedia untuk seluruh produk mie.
  static const List<ToppingItem> defaultToppings = [
    ToppingItem(id: 'top_1', name: 'Telur', price: 4000),
    ToppingItem(id: 'top_2', name: 'Seafood Extra', price: 8000),
    ToppingItem(id: 'top_3', name: 'Ayam Extra', price: 6000),
    ToppingItem(id: 'top_4', name: 'Kerupuk', price: 2000),
  ];
}

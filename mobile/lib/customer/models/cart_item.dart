import 'topping_item.dart';

/// Model untuk satu item di dalam keranjang belanja.
/// Menyimpan produk beserta seluruh kustomisasi yang dipilih pengguna.
class CartItem {
  final String productId;
  final String productName;
  final String productImagePath;
  final int basePrice; // harga dasar produk (integer, tanpa topping)
  final int quantity; // jumlah porsi
  final String spiceLevel; // 'Tidak pedas' | 'Sedang' | 'Pedas'
  final List<ToppingItem> selectedToppings;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.productImagePath,
    required this.basePrice,
    required this.quantity,
    required this.spiceLevel,
    required this.selectedToppings,
  });

  /// Total harga topping per porsi.
  int get toppingPricePerServing {
    return selectedToppings.fold(0, (sum, t) => sum + t.price);
  }

  /// Harga per porsi (dasar + topping).
  int get pricePerServing => basePrice + toppingPricePerServing;

  /// Total harga item ini (pricePerServing × quantity).
  int get totalPrice => pricePerServing * quantity;

  /// Format total harga ke string Rupiah.
  String get formattedTotalPrice {
    final val = totalPrice.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = val.length - 1; i >= 0; i--) {
      buffer.write(val[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  /// Membuat salinan item dengan nilai berbeda.
  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImagePath,
    int? basePrice,
    int? quantity,
    String? spiceLevel,
    List<ToppingItem>? selectedToppings,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImagePath: productImagePath ?? this.productImagePath,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      selectedToppings: selectedToppings ?? this.selectedToppings,
    );
  }

  /// Memeriksa apakah konfigurasi item ini identik dengan [other].
  /// Dua item dianggap identik jika memiliki:
  /// - productId yang sama
  /// - spiceLevel yang sama
  /// - Himpunan topping yang sama (tanpa mempermasalahkan urutan pemilihan)
  bool isIdenticalConfiguration(CartItem other) {
    if (productId != other.productId) return false;
    if (spiceLevel != other.spiceLevel) return false;

    final thisToppingIds = selectedToppings.map((t) => t.id).toSet();
    final otherToppingIds = other.selectedToppings.map((t) => t.id).toSet();

    if (thisToppingIds.length != otherToppingIds.length) return false;
    return thisToppingIds.containsAll(otherToppingIds);
  }
}

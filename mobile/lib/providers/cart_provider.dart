import 'package:flutter/widgets.dart';

import '../models/cart_item.dart';

/// CartNotifier — menyimpan daftar item keranjang dan mengirim notifikasi ke listener.
/// Menggunakan ChangeNotifier agar bisa digunakan dengan ListenableBuilder tanpa
/// dependency pihak ketiga.
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Salinan read-only dari daftar item saat ini.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Jumlah konfigurasi item unik dalam keranjang (untuk badge).
  int get uniqueItemCount => _items.length;

  /// Total seluruh kuantitas porsi dalam keranjang.
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// GlobalKey yang dipasang pada tombol ikon keranjang di header MenuScreen.
  final GlobalKey cartIconKey = GlobalKey();

  /// Cache posisi Rect tombol keranjang di MenuScreen.
  Rect? _cachedCartIconRect;
  Rect? get cachedCartIconRect => _cachedCartIconRect;

  /// Memperbarui cache Rect posisi ikon keranjang.
  void updateCartIconRect(Rect rect) {
    _cachedCartIconRect = rect;
  }

  /// Mengembalikan titik tengah (Offset) dari ikon keranjang untuk target animasi.
  /// Prioritas resolusi:
  /// 1. Posisi aktual dari RenderBox cartIconKey jika sedang terpasang di tree.
  /// 2. Posisi tersimpan dari _cachedCartIconRect.
  /// 3. Fallback matematis berdasarkan layout SmartHeatHeader pada ukuran layar saat ini.
  Offset getCartIconCenter(BuildContext context) {
    final renderBox =
        cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.attached) {
      final origin = renderBox.localToGlobal(Offset.zero);
      final rect = origin & renderBox.size;
      _cachedCartIconRect = rect;
      return rect.center;
    }

    if (_cachedCartIconRect != null) {
      return _cachedCartIconRect!.center;
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final statusBarHeight = mediaQuery.padding.top;
    // Layout SmartHeatHeader:
    // Padding kanan: 16px, Lebar tombol: 44px (tengah = 16 + 22 = 38px dari kanan)
    // Padding atas: 12px + statusBarHeight, Tinggi tombol: 44px (tengah = 12 + 22 = 34px dari top)
    return Offset(screenWidth - 38, statusBarHeight + 34);
  }

  /// Menambahkan item pesanan ke keranjang.
  /// Sesuai spesifikasi:
  /// 1. Cari item keranjang yang memiliki ID produk, tingkat kepedasan, dan
  ///    himpunan topping yang identik (tidak tergantung urutan).
  /// 2. Jika ditemukan, gabungkan dengan menambahkan kuantitas baru ke kuantitas yang ada.
  /// 3. Jika tidak ditemukan, simpan sebagai item baru.
  void addItem(CartItem newItem) {
    final existingIndex = _items.indexWhere(
      (item) => item.isIdenticalConfiguration(newItem),
    );
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + newItem.quantity,
      );
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  /// Menghapus item berdasarkan indeks.
  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Menghapus item berdasarkan konfigurasi identik.
  void removeItem(CartItem target) {
    final index = _items.indexWhere((i) => i.isIdenticalConfiguration(target));
    if (index != -1) {
      removeItemAt(index);
    }
  }

  /// Menambah kuantitas item pada [index] sebanyak satu.
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + 1);
      notifyListeners();
    }
  }

  /// Mengurangi kuantitas item pada [index] sebanyak satu.
  /// Jika kuantitas saat ini adalah 1, baris item langsung dihapus.
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      final current = _items[index];
      if (current.quantity > 1) {
        _items[index] = current.copyWith(quantity: current.quantity - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Menambah kuantitas item berdasarkan konfigurasi identik.
  /// Aman terhadap ketukan beruntun.
  void incrementItem(CartItem target) {
    final index = _items.indexWhere((i) => i.isIdenticalConfiguration(target));
    if (index != -1) {
      incrementQuantity(index);
    }
  }

  /// Mengurangi kuantitas item berdasarkan konfigurasi identik.
  /// Jika kuantitas saat ini adalah 1, baris item langsung dihapus.
  /// Aman terhadap ketukan beruntun.
  void decrementItem(CartItem target) {
    final index = _items.indexWhere((i) => i.isIdenticalConfiguration(target));
    if (index != -1) {
      decrementQuantity(index);
    }
  }

  /// Menghapus seluruh isi keranjang.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// CartProvider — InheritedWidget yang menyimpan CartNotifier di widget tree.
/// Tidak memerlukan dependency eksternal; menggunakan API Flutter bawaan.
class CartProvider extends InheritedNotifier<CartNotifier> {
  const CartProvider({
    super.key,
    required CartNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Mengambil CartNotifier dari context.
  /// Gunakan [listen: false] jika widget tidak perlu rebuild saat cart berubah.
  static CartNotifier of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final provider = context
          .dependOnInheritedWidgetOfExactType<CartProvider>();
      assert(
        provider != null,
        'CartProvider.of() dipanggil di luar CartProvider widget tree.',
      );
      return provider!.notifier!;
    } else {
      final provider = context.getInheritedWidgetOfExactType<CartProvider>();
      assert(
        provider != null,
        'CartProvider.of() dipanggil di luar CartProvider widget tree.',
      );
      return provider!.notifier!;
    }
  }

  /// Mengambil CartNotifier dari context jika tersedia, null jika tidak.
  static CartNotifier? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<CartProvider>()
          ?.notifier;
    } else {
      return context.getInheritedWidgetOfExactType<CartProvider>()?.notifier;
    }
  }
}

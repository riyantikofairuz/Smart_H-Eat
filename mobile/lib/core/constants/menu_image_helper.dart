import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/menu_model.dart';

/// Helper untuk pemetaan dan resolusi aset gambar menu Smart H-EAT.
/// Menghubungkan setiap menu dengan gambar lokal di `assets/images/menu/`
/// melalui AssetManifest agar hanya memuat file yang benar-benar ada di bundle.
class MenuImageHelper {
  static const String baseMenuAssetDir = 'assets/images/menu/';

  static Set<String>? _bundledAssets;

  /// Inisialisasi daftar aset yang ada di dalam bundle aplikasi saat runtime
  static Future<void> init() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final rawAssets = manifest.listAssets();
      final set = <String>{};
      for (final a in rawAssets) {
        set.add(a);
        try {
          set.add(Uri.decodeFull(a));
        } catch (_) {}
        try {
          set.add(Uri.encodeFull(a));
        } catch (_) {}
      }
      _bundledAssets = set;
    } catch (e) {
      debugPrint('[MenuImageHelper] Gagal memuat AssetManifest: $e');
      _bundledAssets = {};
    }
  }

  /// Memastikan daftar aset bundle terinisialisasi
  static Future<void> ensureInitialized() async {
    if (_bundledAssets == null) {
      await init();
    }
  }

  /// Set daftar aset secara manual (berguna untuk testing atau mocking)
  @visibleForTesting
  static void setBundledAssetsForTesting(Set<String>? assets) {
    _bundledAssets = assets;
  }

  /// Daftar pemetaan aset standar untuk 12 menu default Smart H-EAT
  static const Map<String, String> defaultMenuImages = {
    // Kategori: Nasi
    'nasi cumi hitam': 'assets/images/menu/Nasi Cumi Hitam.jpg',
    'nasi ayam bakar madu': 'assets/images/menu/Nasi Ayam Bakar Madu.jpg',
    'nasi uduk komplit telur balado': 'assets/images/menu/Nasi Uduk Komplit Telur Balado.jpg',
    'nasi rendang sapi hangat': 'assets/images/menu/Nasi Rendang Sapi Hangat.jpg',
    'nasi kuning gurih ayam suwir': 'assets/images/menu/Nasi Kuning Gurih Ayam Suwir.jpg',
    'bento nasi ayam teriyaki': 'assets/images/menu/Bento Nasi Ayam Teriyaki.jpg',

    // Kategori: Sup & Kuah
    'sup ayam jamur panas': 'assets/images/menu/Sup Ayam Jamur Panas.jpg',
    'soto ayam lamongan hangat': 'assets/images/menu/Soto Ayam Lamongan Hangat.jpg',

    // Kategori: Mie & Pasta
    'mie tarempa lembab seafood': 'assets/images/menu/Mie Tarempa Lembab.jpg',
    'mie tarempa banjir': 'assets/images/menu/Mie Tarempa Banjir.jpg',
    'spaghetti bolognese hangat': 'assets/images/menu/Spaghetti Bolognese Hangat.jpg',
    'kwetiau goreng seafood hangat': 'assets/images/menu/Kwetiau Goreng Seafood Hangat.jpg',
  };

  /// Mengubah nama menu menjadi nama file slug standar (contoh: "Roti Bakar Keju" -> "roti_bakar_keju")
  static String slugify(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Mendapatkan daftar kandidat path gambar yang mungkin digunakan untuk menu ini.
  static List<String> getCandidateAssetPaths(MenuModel menu) {
    final candidates = <String>[];

    // 1. Jika menu memiliki properti imageUrl eksplisit (dari database / form)
    if (menu.imageUrl != null && menu.imageUrl!.trim().isNotEmpty) {
      final img = menu.imageUrl!.trim();
      if (img.startsWith('assets/') ||
          img.startsWith('http://') ||
          img.startsWith('https://')) {
        candidates.add(img);
      } else {
        candidates.add('$baseMenuAssetDir$img');
      }
    }

    final rawName = menu.name.trim();
    final slug = slugify(rawName);
    final normalized = rawName.toLowerCase();

    // 2. Pemetaan default eksplisit
    if (defaultMenuImages.containsKey(normalized)) {
      candidates.add(defaultMenuImages[normalized]!);
    }

    // 3. Nama persis (TitleCase / spasi) dengan ekstensi umum
    final extensions = ['.jpg', '.png', '.jpeg', '.webp'];
    for (final ext in extensions) {
      candidates.add('$baseMenuAssetDir$rawName$ext');
    }

    // 4. Variasi tanpa kata pelengkap (misal "Mie Tarempa Lembab Seafood" -> "Mie Tarempa Lembab")
    final withoutKeywords = rawName
        .replaceAll(RegExp(r'\b(Seafood|Hangat|Panas|Spesial)\b', caseSensitive: false), '')
        .trim();
    if (withoutKeywords != rawName && withoutKeywords.isNotEmpty) {
      for (final ext in extensions) {
        candidates.add('$baseMenuAssetDir$withoutKeywords$ext');
      }
    }

    // 5. Format slug/snake_case dengan ekstensi umum
    for (final ext in extensions) {
      candidates.add('$baseMenuAssetDir$slug$ext');
    }

    // Hapus duplikat sambil menjaga prioritas urutan
    return candidates.toSet().toList();
  }

  /// Mencari path aset yang BENAR-BENAR TERSEDIA di asset bundle aplikasi.
  /// Jika ada di manifest atau ada di pemetaan terverifikasi, mengembalikan path tersebut.
  /// Jika tidak ada aset yang tersedia, mengembalikan null agar langsung menampilkan placeholder.
  static String? resolveExistingAssetPath(MenuModel menu) {
    // Jika menu memiliki imageUrl berupa jaringan (http/https), kembalikan langsung
    if (menu.imageUrl != null &&
        (menu.imageUrl!.startsWith('http://') || menu.imageUrl!.startsWith('https://'))) {
      return menu.imageUrl;
    }

    final candidates = getCandidateAssetPaths(menu);

    // Jika manifest sudah dimuat, hanya pilih yang benar-benar ada di bundle
    if (_bundledAssets != null && _bundledAssets!.isNotEmpty) {
      for (final candidate in candidates) {
        if (_bundledAssets!.contains(candidate) ||
            _bundledAssets!.contains(Uri.encodeFull(candidate)) ||
            _bundledAssets!.contains(Uri.decodeFull(candidate))) {
          return candidate;
        }
      }
      return null;
    }

    // Fallback jika manifest belum dimuat (misal pada widget test synchronous awal):
    final normalized = menu.name.trim().toLowerCase();
    if (defaultMenuImages.containsKey(normalized)) {
      return defaultMenuImages[normalized];
    }

    return candidates.isNotEmpty ? candidates.first : null;
  }

  /// Mendapatkan path aset default berdasarkan nama menu
  static String getDefaultAssetPathForName(String name) {
    final normalized = name.trim().toLowerCase();
    if (defaultMenuImages.containsKey(normalized)) {
      return defaultMenuImages[normalized]!;
    }
    final rawName = name.trim();
    return '$baseMenuAssetDir$rawName.jpg';
  }

  /// Resolusi path gambar utama untuk objek MenuModel
  static String resolveImagePath(MenuModel menu) {
    return resolveExistingAssetPath(menu) ?? getDefaultAssetPathForName(menu.name);
  }

  /// Mendapatkan ikon representatif berdasarkan kategori makanan untuk placeholder
  static IconData getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('nasi')) {
      return Icons.rice_bowl_rounded;
    } else if (lower.contains('sup') || lower.contains('kuah') || lower.contains('soto')) {
      return Icons.soup_kitchen_rounded;
    } else if (lower.contains('mie') || lower.contains('pasta') || lower.contains('kwetiau')) {
      return Icons.ramen_dining_rounded;
    }
    return Icons.restaurant_rounded;
  }
}

import '../models/banner_item.dart';
import '../models/product_item.dart';

class DummyData {
  static const List<String> categories = ['Semua', 'Kering', 'Lembab', 'Basah'];

  static const List<BannerItem> banners = [
    BannerItem(
      id: 'banner_1',
      title: 'Mie Tarempa Spesial Autentik',
      imagePath: 'assets/images/banners/banner_1.jpg',
    ),
    BannerItem(
      id: 'banner_2',
      title: 'Promo Pilihan Hari Ini',
      imagePath: 'assets/images/banners/banner_2.jpg',
    ),
    BannerItem(
      id: 'banner_3',
      title: 'Kelezatan Kuah Hangat Gurih',
      imagePath: 'assets/images/banners/banner_3.jpg',
    ),
  ];

  static const List<ProductItem> products = [
    ProductItem(
      id: 'prod_1',
      name: 'Mie Tarempa Lembab Seafood',
      price: 28000,
      category: 'Lembab',
      imagePath: 'assets/images/products/mie_tarempa_lembab.jpg',
      description: 'Mie pipih khas Tarempa dengan saus lembab gurih pedas, cumi, udang segar, telur mata sapi, dan cabai rawit utuh.',
    ),
    ProductItem(
      id: 'prod_2',
      name: 'Mie Tarempa Lembab Ayam',
      price: 25000,
      category: 'Lembab',
      imagePath: 'assets/images/products/mie_tarempa_lembab_ayam.jpg',
      description: 'Mie Tarempa tekstur lembab dengan suwiran ayam gurih, bumbu rempah pilihan, dan taburan bawang goreng renyah.',
    ),
    ProductItem(
      id: 'prod_3',
      name: 'Mie Tarempa Kering Seafood',
      price: 28000,
      category: 'Kering',
      imagePath: 'assets/images/products/mie_tarempa_kering.jpg',
      description: 'Mie Tarempa goreng kering renyah gurih dengan potongan seafood melimpah dan telur mata sapi lezat.',
    ),
    ProductItem(
      id: 'prod_4',
      name: 'Mie Tarempa Kering Spesial',
      price: 30000,
      category: 'Kering',
      imagePath: 'assets/images/products/mie_tarempa_kering_spesial.jpg',
      description: 'Varian kering spesial dengan topping ganda ayam dan seafood serta telur ceplok khas Smart H-Eat.',
    ),
    ProductItem(
      id: 'prod_5',
      name: 'Mie Tarempa Basah Seafood',
      price: 28000,
      category: 'Basah',
      imagePath: 'assets/images/products/mie_tarempa_basah.jpg',
      description: 'Mie Tarempa berkuah kental nikmat kaya rempah disajikan hangat dengan aneka sari laut pilihan.',
    ),
    ProductItem(
      id: 'prod_6',
      name: 'Mie Tarempa Basah Spesial',
      price: 32000,
      category: 'Basah',
      imagePath: 'assets/images/products/mie_tarempa_basah_seafood.jpg',
      description: 'Mie kuah basah porsi spesial dengan kuah rempah mendidih hangat khas vending machine Smart H-Eat.',
    ),
    ProductItem(
      id: 'prod_7',
      name: 'Mie Tarempa Lembab Daging',
      price: 30000,
      category: 'Lembab',
      imagePath: 'assets/images/products/mie_tarempa_lembab_daging.jpg',
      description: 'Mie Tarempa bertekstur lembab dipadu irisan daging sapi empuk bercita rasa manis gurih khas Melayu.',
    ),
  ];
}

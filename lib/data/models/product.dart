// lib/data/models/product.dart

class Product {
  final int id;
  final String ad;
  final String resim;
  final String kategori;
  final int fiyat;
  final String marka;

  Product({
    required this.id,
    required this.ad,
    required this.resim,
    required this.kategori,
    required this.fiyat,
    required this.marka,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      ad: json['ad'] as String,
      resim: json['resim'] as String,
      kategori: json['kategori'] as String,
      fiyat: json['fiyat'] as int,
      marka: json['marka'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'resim': resim,
      'kategori': kategori,
      'fiyat': fiyat,
      'marka': marka,
    };
  }
}

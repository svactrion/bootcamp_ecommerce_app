// lib/data/models/cart_item.dart

class CartItem {
  final int sepetId;
  final String ad;
  final String resim;
  final String kategori;
  final int fiyat;
  final String marka;
  final int siparisAdeti;
  final String kullaniciAdi;

  CartItem({
    required this.sepetId,
    required this.ad,
    required this.resim,
    required this.kategori,
    required this.fiyat,
    required this.marka,
    required this.siparisAdeti,
    required this.kullaniciAdi,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    sepetId: json['sepetId'] as int,
    ad: json['ad'] as String,
    resim: json['resim'] as String,
    kategori: json['kategori'] as String,
    fiyat: json['fiyat'] as int,
    marka: json['marka'] as String,
    siparisAdeti: json['siparisAdeti'] as int,
    kullaniciAdi: json['kullaniciAdi'] as String,
  );
}

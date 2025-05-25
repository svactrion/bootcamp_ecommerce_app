// lib/data/services/web_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../models/tum_urunler_response.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class WebService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://kasimadalan.pe.hu/urunler'),
  );

  // PHP'nin $_POST ile okuyacağı form-url-encoded içerik tipi
  static final Options _form = Options(
    contentType: Headers.formUrlEncodedContentType,
  );

  /// 0) Tüm ürünleri getir (GET)
  Future<TumUrunlerResponse> fetchAllProducts() async {
    final r = await _dio.get('/tumUrunleriGetir.php');
    final Map<String, dynamic> data =
        r.data is String
            ? jsonDecode(r.data as String)
            : r.data as Map<String, dynamic>;
    print('fetchAllProducts response: $data');
    return TumUrunlerResponse.fromJson(data);
  }

  /// 1) Sepete ürün ekle (POST)
  Future<bool> addToCart({
    required Product product,
    required int siparisAdeti,
  }) async {
    final r = await _dio.post(
      '/sepeteUrunEkle.php',
      data: {
        'ad': product.ad,
        'resim': product.resim,
        'kategori': product.kategori,
        'fiyat': product.fiyat,
        'marka': product.marka,
        'siparisAdeti': siparisAdeti,
        'kullaniciAdi': AppConfig.currentUser, // ← camelCase
      },
      options: _form,
    );
    final resp =
        r.data is String
            ? jsonDecode(r.data as String)
            : r.data as Map<String, dynamic>;
    print('addToCart response: $resp');
    return resp['success'] == 1;
  }

  /// 2) Sepetteki ürünleri getir (POST)
  // lib/data/services/web_service.dart

  Future<List<CartItem>> fetchCartItems() async {
    try {
      final r = await _dio.post(
        '/sepettekiUrunleriGetir.php',
        data: {'kullaniciAdi': AppConfig.currentUser},
        options: _form,
      );

      final body =
          r.data is String
              ? jsonDecode(r.data as String)
              : r.data as Map<String, dynamic>;

      print('fetchCartItems raw response: $body');

      final dynamic rawList = body['urunler_sepeti'];
      if (rawList is List) {
        return rawList
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return <CartItem>[];
      }
    } catch (e, s) {
      print('fetchCartItems error: $e\n$s');
      return <CartItem>[]; // Hata durumunda boş liste döndür
    }
  }

  /// 3) Sepetten ürün silme (POST)
  Future<bool> removeFromCart({required int sepetId}) async {
    final r = await _dio.post(
      '/sepettenUrunSil.php',
      data: {
        'sepetId': sepetId,
        'kullaniciAdi': AppConfig.currentUser, // ← camelCase
      },
      options: _form,
    );
    final resp =
        r.data is String
            ? jsonDecode(r.data as String)
            : r.data as Map<String, dynamic>;
    print('removeFromCart response: $resp');
    return resp['success'] == 1;
  }
}

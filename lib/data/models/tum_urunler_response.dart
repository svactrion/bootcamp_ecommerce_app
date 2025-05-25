// lib/data/models/tum_urunler_response.dart

import 'product.dart';

class TumUrunlerResponse {
  final List<Product> urunler;
  final int success;

  TumUrunlerResponse({required this.urunler, required this.success});

  factory TumUrunlerResponse.fromJson(Map<String, dynamic> json) {
    return TumUrunlerResponse(
      success: json['success'] as int,
      urunler:
          (json['urunler'] as List<dynamic>)
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

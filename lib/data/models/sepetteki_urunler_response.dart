// lib/data/models/sepetteki_urunler_response.dart

import 'cart_item.dart';

class SepettekiUrunlerResponse {
  final List<CartItem> urunler;
  final int success;
  final String? message;

  SepettekiUrunlerResponse({
    required this.urunler,
    required this.success,
    this.message,
  });

  factory SepettekiUrunlerResponse.fromJson(Map<String, dynamic> json) {
    // JSON’daki anahtar: "urunler_sepeti"
    final rawList = json['urunler_sepeti'] as List<dynamic>? ?? [];
    final items =
        rawList
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();

    return SepettekiUrunlerResponse(
      urunler: items,
      success: json['success'] as int,
      message: json['message'] as String?,
    );
  }
}

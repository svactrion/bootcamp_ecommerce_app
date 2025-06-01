// lib/data/repositories/cart_repository.dart

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/web_service.dart';

class CartRepository {
  final WebService _ws;
  CartRepository(this._ws);

  /// Mevcut sepeti çeker.
  Future<List<CartItem>> fetchCartItems() async {
    return await _ws.fetchCartItems();
  }

  /// Sepete yeni bir ürün ekler.
  Future<bool> addToCart(Product product, int quantity) async {
    return await _ws.addToCart(
      product: product,
      siparisAdeti: quantity,
    );
  }

  /// Sepet öğesini siler.
  Future<bool> removeFromCart(int cartItemId) async {
    return await _ws.removeFromCart(
      sepetId: cartItemId,
    );
  }

  /// Siparişi değiştirecek bir "güncelleme" endpoint'i yoksa,
  /// bu metot “mevcut satırı silip, yeni miktarla tekrar ekler”.
  Future<bool> mergeCartItem({
    required CartItem existingItem,
    required Product product,
    required int newQuantity,
  }) async {
    // 1) Mevcut satırı sil
    final removed = await removeFromCart(existingItem.sepetId);
    if (!removed) return false;

    // 2) Yeni miktarla tekrar ekle
    final added = await addToCart(product, newQuantity);
    return added;
  }
}

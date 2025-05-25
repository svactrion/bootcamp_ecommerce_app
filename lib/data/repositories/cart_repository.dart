// lib/data/repositories/cart_repository.dart

import '../services/web_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository {
  final WebService _ws;
  CartRepository(this._ws);

  /// Sepete ekleme — değişmedi
  Future<bool> addToCart(Product product, int quantity) {
    return _ws.addToCart(product: product, siparisAdeti: quantity);
  }

  /// Sepetteki ürünleri getir — artık doğrudan List<CartItem>
  Future<List<CartItem>> fetchCartItems() {
    return _ws.fetchCartItems();
  }

  /// Sepetten ürünü sil — değişmedi
  Future<bool> removeFromCart(int cartItemId) {
    return _ws.removeFromCart(sepetId: cartItemId);
  }
}

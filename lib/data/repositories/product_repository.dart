// lib/data/repositories/product_repository.dart

import '../services/web_service.dart';
import '../models/product.dart';

class ProductRepository {
  final WebService _ws;
  ProductRepository(this._ws);

  /// Tüm ürünleri getir ve direkt List<Product> döndür
  Future<List<Product>> fetchAll() async {
    final resp = await _ws.fetchAllProducts();
    return resp.urunler;
  }
}

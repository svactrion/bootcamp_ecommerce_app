// Gerekli dosyaları içe aktarır:
// - WebService sınıfı, API'den veri alma işini yapar.
// - Product modeli, alınan ürün verilerini temsil eder.
import '../services/web_service.dart';
import '../models/product.dart';

// Bu sınıf, ürün verilerini almak için repository katmanıdır.
// Amaç: UI ve veri katmanlarını ayırmak. Böylece test edilebilirlik ve sürdürülebilirlik sağlanır.
class ProductRepository {
  final WebService _ws; // API çağrılarını gerçekleştirecek servis sınıfı

  // Constructor: dışarıdan WebService alır (bağımlılık enjekte edilir).
  ProductRepository(this._ws);

  // Tüm ürünleri getirir.
  // Bu metot UI tarafında ProductBloc gibi yerler tarafından çağrılır.
  Future<List<Product>> fetchAll() async {
    // WebService üzerinden tüm ürünleri al
    final resp = await _ws.fetchAllProducts();

    // Dönen cevaptan sadece ürün listesini çıkar ve return et
    return resp.urunler;
  }
}

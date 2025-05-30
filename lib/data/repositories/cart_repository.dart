// Gerekli dosyaları içe aktarır:
// - WebService: API işlemlerini yürütür
// - CartItem: Sepetteki ürünleri temsil eden model
// - Product: Sepete eklenecek ürünleri temsil eden model
import '../services/web_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

// Bu sınıf, sepete ürün ekleme, silme ve sepeti listeleme işlemlerini gerçekleştirir.
// Amaç: CartBloc gibi yapılar bu sınıfı kullanarak veriyle ilgilenir.
class CartRepository {
  final WebService _ws; // API işlemlerini yönetecek servis sınıfı

  // Constructor: WebService nesnesi dışarıdan alınır (dependency injection)
  CartRepository(this._ws);

  /// Sepete ürün ekler.
  /// [product] → eklenecek ürün
  /// [quantity] → adet bilgisi
  /// Kullanıldığı yer: DetailScreen'deki "Sepete Ekle" butonu
  Future<bool> addToCart(Product product, int quantity) {
    return _ws.addToCart(product: product, siparisAdeti: quantity);
  }

  /// Sepetteki tüm ürünleri getirir.
  /// Dönen değer: List<CartItem>
  /// Kullanıldığı yer: CartBloc → CartScreen (sepet ekranı)
  Future<List<CartItem>> fetchCartItems() {
    return _ws.fetchCartItems();
  }

  /// Sepetten ürün siler.
  /// [cartItemId] → silinecek sepet öğesinin ID'si
  /// Kullanıldığı yer: CartScreen → ürün yanındaki çöp kutusu ikonu
  Future<bool> removeFromCart(int cartItemId) {
    return _ws.removeFromCart(sepetId: cartItemId);
  }
}

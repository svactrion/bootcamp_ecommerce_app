// Gerekli importlar: ekran navigasyonu, BLoC’lar ve ürün modeli
import 'package:bootcamp_ecommerce_app/ui/screens/main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../data/models/product.dart';

// DetailScreen widget'ı – bir ürünün detaylarını gösteren ekran
class DetailScreen extends StatefulWidget {
  static const routeName = '/detail'; // Route ismi

  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

// Stateful çünkü quantity ve favorite durumu değişebilir
class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1; // Ürün adedi
  bool _isFavorite = false; // Favori durumu

  @override
  Widget build(BuildContext context) {
    // Ürün bilgisi route arguments'tan alınıyor
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    // Bloc'lar context üzerinden çağrılıyor
    final cartBloc = context.read<CartBloc>();
    final favBloc = context.read<FavoritesBloc>();

    return Scaffold(
      // Üst kısımdaki AppBar – ürün adı yazıyor
      appBar: AppBar(
        title: Text(
          product.ad,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(),
        elevation: 1,
        backgroundColor: const Color(0xFFFF6000),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Ürün görseli
              AspectRatio(
                aspectRatio: 1.0, // Kare görünüm
                child: Image.network(
                  'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Ürün adı ve favori butonu
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.ad,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite); // Toggle
                      if (_isFavorite) {
                        favBloc.add(AddFavorite(product)); // Favoriye ekle
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Favorilere eklendi')),
                        );
                      } else {
                        favBloc.add(RemoveFavorite(product.id)); // Kaldır
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Favorilerden kaldırıldı'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fiyat
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${product.fiyat} TL',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Kategori ve Marka bilgisi
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Kategori: ${product.kategori}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Marka: ${product.marka}'),
              ),
              const SizedBox(height: 24),

              // Adet seçme arayüzü
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_quantity', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const Spacer(),

              // Sepete ekle ve hemen satın al butonları
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Sepete Ekle',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        // Artık doğrudan repository değil, Bloc event’i çağrıyoruz:
                        cartBloc.add(
                          AddProductToCart(
                            product: product,
                            quantity: _quantity,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ürün sepete eklendi')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text(
                        'Hemen Satın Al',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        // Yine doğrudan repository yerine Bloc event’i:
                        cartBloc.add(
                          AddProductToCart(
                            product: product,
                            quantity: _quantity,
                          ),
                        );
                        // Sepeti güncelle ve doğrudan Sepet tab’ına yönlendir
                        cartBloc.add(LoadCart());
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(); // Bu ekranı kapat
                        navController.jumpToTab(2); // Sepet tab'ına geç
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

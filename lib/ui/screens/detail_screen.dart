// lib/ui/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../data/models/product.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';

  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cartBloc = context.read<CartBloc>();
    final favBloc = context.read<FavoritesBloc>();

    return Scaffold(
      // Ana navigasyonun app bar’ı yerine sayfa başlığı olarak ürün adı
      appBar: AppBar(
        title: Text(product.kategori),
        leading: const BackButton(),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Ürün görseli
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Başlık + Favori butonu
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
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      if (_isFavorite) {
                        favBloc.add(AddFavorite(product));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Favorilere eklendi')),
                        );
                      } else {
                        favBloc.add(RemoveFavorite(product.id));
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
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),

              // Kategori & Marka
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Kategori: ${product.kategori}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Marka: ${product.marka}'),
              ),
              const SizedBox(height: 24),

              // Adet seçici
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

              // Sepete Ekle & Hemen Satın Al
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Sepete Ekle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        final ok = await cartBloc.repository.addToCart(
                          product,
                          _quantity,
                        );
                        if (ok) {
                          cartBloc.add(LoadCart());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ürün sepete eklendi'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text('Hemen Satın Al'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        final ok = await cartBloc.repository.addToCart(
                          product,
                          _quantity,
                        );
                        if (ok) {
                          cartBloc.add(LoadCart());
                          // Burada pushReplacement ile aynı route’a tekrar gideriz:
                          Navigator.pushReplacementNamed(
                            context,
                            CartScreen.routeName,
                          );
                        }
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

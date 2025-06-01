// lib/ui/screens/detail_screen.dart

import 'package:bootcamp_ecommerce_app/ui/screens/main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../data/models/product.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';

  const DetailScreen({super.key});

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
      appBar: AppBar(
        title: Text(
          '${product.marka} ${product.ad}', // Marka + Ad
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        elevation: 1,
        backgroundColor: const Color(0xFFFF6000),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Ürün görseli: hafif gölgeli ve köşeleri yuvarlak
              AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.network(
                      'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ürün adı ve favori butonu, altına fiyat
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${product.marka} ${product.ad}', // Marka + Ad
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                      size: 30,
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
              const SizedBox(height: 4),
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
              const SizedBox(height: 12),

              // Kategori ve Marka bilgisi tek satırda, hafif gri tonda
              Row(
                children: [
                  Text(
                    'Kategori: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    product.kategori,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Marka: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    product.marka,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Adet seçme arayüzü, etrafı çerçeveli
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color:
                            _quantity > 1
                                ? Colors.redAccent
                                : Colors.grey.shade400,
                      ),
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Sepete ekle ve hemen satın al butonları, genişçe ve yuvarlak köşeli
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
                        backgroundColor: const Color(0xFF138808),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
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
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.payment, // İkon eklendi
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
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
                        cartBloc.add(
                          AddProductToCart(
                            product: product,
                            quantity: _quantity,
                          ),
                        );
                        cartBloc.add(LoadCart());
                        Navigator.of(context).pop();
                        navController.jumpToTab(2);
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

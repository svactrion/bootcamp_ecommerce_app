// lib/ui/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../blocs/cart/cart_bloc.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';

  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Navigator üzerinden gelen ürünü al
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cartBloc = context.read<CartBloc>();

    return Scaffold(
      appBar: AppBar(title: Text(product.ad)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ürün görseli
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // Ürün adı
            Text(
              product.ad,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Fiyat
            Text(
              '${product.fiyat} TL',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 8),
            // Kategori ve marka
            Text('Kategori: ${product.kategori}'),
            Text('Marka: ${product.marka}'),
            const SizedBox(height: 24),

            // Adet seçici
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sepete Ekle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Sepete Ekle'),
                onPressed: () async {
                  final success = await cartBloc.repository.addToCart(
                    product,
                    _quantity,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ürün sepete eklendi')),
                    );
                    cartBloc.add(LoadCart()); // opsiyonel: hemen güncelle
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ürün sepete eklenemedi')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

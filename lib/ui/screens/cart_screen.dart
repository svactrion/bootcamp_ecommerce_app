// lib/ui/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cart/cart_bloc.dart';
import '../../data/models/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 1) Sepet tamamen boşsa:
          if (state is CartEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sepetiniz boş',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Ana ekrana dön
                      Navigator.pop(context);
                    },
                    child: const Text('Alışverişe dön'),
                  ),
                ],
              ),
            );
          }

          // 2) Sepet yüklendiyse:
          if (state is CartLoaded) {
            final items = state.items;

            final totalPrice = items.fold<double>(
              0,
              (sum, item) => sum + item.fiyat * item.siparisAdeti,
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final CartItem item = items[index];
                      final lineTotal = item.fiyat * item.siparisAdeti;

                      return ListTile(
                        leading: Image.network(
                          'http://kasimadalan.pe.hu/urunler/resimler/${item.resim}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.ad),
                        subtitle: Text(
                          '${item.fiyat} TL × ${item.siparisAdeti} = $lineTotal TL',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<CartBloc>().add(
                              RemoveProductFromCart(item.sepetId),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} TL',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // 3) Sadece gerçek bir hata varsa:
          if (state is CartError) {
            return Center(
              child: Text(
                'Hata: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 4) Hiçbir durum değilse boş bırak:
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

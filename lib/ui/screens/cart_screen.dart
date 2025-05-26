// lib/ui/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cart/cart_bloc.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          // AppBar her iki yoldan da gelecek şekilde aynı:
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state is CartLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CartError) {
      return Center(
        child: Text(
          'Hata: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

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
              'Sepetiniz şu anda boş.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
              child: const Text('Alışverişe Başla'),
            ),
          ],
        ),
      );
    }

    if (state is CartLoaded) {
      final items = state.items;
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.fiyat * item.siparisAdeti,
      );

      String itemCountLabel =
          'Subtotal (${items.length} item${items.length > 1 ? 's' : ''})';

      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final item = items[i];
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
                    icon: const Icon(Icons.delete_outline),
                    onPressed:
                        () => context.read<CartBloc>().add(
                          RemoveProductFromCart(item.sepetId),
                        ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildPriceRow(
                  itemCountLabel,
                  '${subtotal.toStringAsFixed(2)} TL',
                ),
                const SizedBox(height: 4),
                _buildPriceRow(
                  'Total',
                  '${subtotal.toStringAsFixed(2)} TL',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(ClearCart()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Sepeti Boşalt'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Alışverişi Tamamla'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

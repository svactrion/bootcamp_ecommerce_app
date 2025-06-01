// lib/ui/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import 'main_screen_controller.dart'; // “navController” için

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Sepetim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 1,
            backgroundColor: const Color(0xFF138808), // Yeşil ton
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF138808), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    // 1) Yükleniyorsa
    if (state is CartLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Hata varsa
    if (state is CartError) {
      return Center(
        child: Text(
          'Hata: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // 3) Sepet boşsa
    if (state is CartEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.black54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sepetiniz şu anda boş.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Ana sayfaya (Home sekmesi) dönecek
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
                navController.jumpToTab(0);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, // Metin rengi
                backgroundColor: Colors.white, // Buton arkaplan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Alışverişe Başla'),
            ),
          ],
        ),
      );
    }

    // 4) Sepet doluysa
    if (state is CartLoaded) {
      final items = state.items;
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.fiyat * item.siparisAdeti,
      );
      final itemCountLabel =
          'Subtotal (${items.length} item${items.length > 1 ? 's' : ''})';

      return Column(
        children: [
          // 4.1) Ürün listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                final lineTotal = item.fiyat * item.siparisAdeti;
                return Dismissible(
                  key: Key(item.sepetId.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context.read<CartBloc>().add(
                      RemoveProductFromCart(item.sepetId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.ad} sepetten kaldırıldı')),
                    );
                  },
                  child: Card(
                    color: const Color(0xFFF8F9FA),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
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
                        onPressed: () {
                          context.read<CartBloc>().add(
                            RemoveProductFromCart(item.sepetId),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 4.2) Alt toplam ve toplam
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

          const Divider(height: 1),

          // 4.3) Aksiyon butonları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Sepeti Boşalt
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(ClearCart());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Sepeti Boşalt',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Alışverişi Tamamla
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder:
                            (_) => Padding(
                              padding: EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 24,
                                // Klavyeden etkilenmesi için viewInsets + fazladan boşluk
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    250,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Kart Bilgisi",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: '4242 4242 4242 4242',
                                        labelText: 'Kart Numarası',
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 16,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'AA/YY',
                                              labelText: 'AA/YY',
                                            ),
                                            maxLength: 4,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'CVV',
                                              labelText: 'CVV',
                                            ),
                                            keyboardType: TextInputType.number,
                                            obscureText: true,
                                            maxLength: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        context.read<CartBloc>().add(
                                          ClearCart(),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Simülasyon: Ödeme başarılı",
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Ödemeyi Onayla",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },

                    child: const Text(
                      'Alışverişi Tamamla',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 5) Diğer durumlar
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

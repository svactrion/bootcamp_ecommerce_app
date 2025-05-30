// lib/ui/screens/cart_screen.dart

// Ana navigasyon controller'ı (tablar arasında geçiş için)
import 'main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';

// StatelessWidget olarak tanımlanmış CartScreen
class CartScreen extends StatelessWidget {
  static const routeName = '/cart'; // Bu ekranın route adı

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sepet durumu CartBloc üzerinden dinleniyor
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sepetim'),
            centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.orangeAccent, // AppBar rengi
          ),
          // Arka plan geçişli renk için Container kullanılıyor
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildBody(
              context,
              state,
            ), // Sepet durumu burada ele alınıyor
          ),
        );
      },
    );
  }

  // Sepet durumu için içerik oluşturan fonksiyon
  Widget _buildBody(BuildContext context, CartState state) {
    // Yükleniyor durumundaysa loading göster
    if (state is CartLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata durumu
    if (state is CartError) {
      return Center(
        child: Text(
          'Hata: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Sepet boşsa kullanıcıya bilgi ver ve alışverişe başlat
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
                // Kullanıcıyı ana sayfaya yönlendir
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
                navController.jumpToTab(0); // Home sekmesine geç
              },
              child: const Text('Alışverişe Başla'),
            ),
          ],
        ),
      );
    }

    // Sepet doluysa ürünleri göster
    if (state is CartLoaded) {
      final items = state.items;

      // Toplam fiyat hesaplaması
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.fiyat * item.siparisAdeti,
      );

      final itemCountLabel =
          'Subtotal (${items.length} item${items.length > 1 ? 's' : ''})';

      return Column(
        children: [
          // Ürün listesi
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final item = items[i];

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
                    // Ürün silindiğinde bloc'a event gönderiliyor
                    context.read<CartBloc>().add(
                      RemoveProductFromCart(item.sepetId),
                    );

                    // Geri bildirim olarak snackbar gösteriliyor
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.ad} sepetten kaldırıldı')),
                    );
                  },
                  child: ListTile(
                    leading: Image.network(
                      'http://kasimadalan.pe.hu/urunler/resimler/${item.resim}',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.ad),
                    subtitle: Text(
                      '${item.fiyat} TL × ${item.siparisAdeti} = ${item.fiyat * item.siparisAdeti} TL',
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
                );
              },
            ),
          ),
          const Divider(),

          // Toplam tutar alanı
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

          // Sepeti boşalt ve tamamla butonları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(ClearCart());
                    },
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
                    onPressed: null, // Henüz fonksiyonu tanımlanmadı
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

    // Diğer durumlar için boş widget
    return const SizedBox.shrink();
  }

  // Toplam ve ara toplam satırlarını çizen yardımcı widget
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

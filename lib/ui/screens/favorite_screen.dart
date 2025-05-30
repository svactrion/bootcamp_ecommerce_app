// Gerekli kütüphaneler
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import 'detail_screen.dart';

// FavoriteScreen widget'ı
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  static const routeName = '/favorites'; // Route için sabit tanım

  @override
  Widget build(BuildContext context) {
    final cartBloc =
        context
            .read<CartBloc>(); // Sepete ürün eklemek için CartBloc kullanılır

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'), // Sayfa başlığı
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.amberAccent,
      ),

      // Arka plan için linear gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        // Favori ürünleri BLoC üzerinden dinler
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            // Eğer yüklenmişse ve favori ürün varsa
            if (state is FavoritesLoaded && state.favorites.isNotEmpty) {
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final product = state.favorites[index];

                  return Dismissible(
                    key: Key(product.id.toString()),
                    direction: DismissDirection.endToStart, // Sola kaydırma
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),

                    // Sola kaydırınca favoriden çıkarma
                    onDismissed: (_) {
                      context.read<FavoritesBloc>().add(
                        RemoveFavorite(product.id),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.ad} favorilerden kaldırıldı',
                          ),
                        ),
                      );
                    },

                    // Ürün kartı tasarımı
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 4,

                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        // Ürün resmi
                        leading: Image.network(
                          'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),

                        // Ürün adı
                        title: Text(product.ad),

                        // Fiyat bilgisi
                        subtitle: Text('${product.fiyat} TL'),

                        // Tıklayınca detay sayfasına geçiş
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pushNamed(
                            DetailScreen.routeName,
                            arguments: product,
                          );
                        },

                        // "Sepete Ekle" butonu
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final ok = await cartBloc.repository.addToCart(
                              product,
                              1, // varsayılan olarak 1 adet
                            );
                            if (ok) {
                              cartBloc.add(LoadCart()); // sepeti güncelle
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.ad} sepete eklendi'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sepete Ekle",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            // Favori listesi boşsa gösterilecek ekran
            return const Center(child: Text('Favori ürününüz bulunmamaktadır'));
          },
        ),
      ),
    );
  }
}

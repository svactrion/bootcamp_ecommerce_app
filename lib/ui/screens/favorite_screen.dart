// lib/ui/screens/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/favorites/favorites_bloc.dart';
import '../../data/models/product.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Favoriler Bloc zaten main.dart'da başlatılıyor
    return Scaffold(
      appBar: AppBar(title: const Text('Favoriler')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesInitial) {
            // İlk durum, Bloc init sırasında LoadFavorites() çağırıyor
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesError) {
            return Center(child: Text('Hata: ${state.message}'));
          } else if (state is FavoritesLoaded) {
            final List<Product> favs = state.favorites;
            if (favs.isEmpty) {
              return const Center(child: Text('Henüz favori yok'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favs.length,
              itemBuilder: (ctx, i) {
                final product = favs[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.ad),
                    subtitle: Text('${product.fiyat} TL'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                          RemoveFavorite(product.id),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Favoriden kaldırıldı')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        DetailScreen.routeName,
                        arguments: product,
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

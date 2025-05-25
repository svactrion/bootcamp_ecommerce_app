import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bootcamp_ecommerce_app/ui/screens/favorite_screen.dart';

import '../../blocs/product/product_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed:
                () => Navigator.pushNamed(context, FavoritesScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) => searchBloc.add(SearchQueryChanged(q)),
            ),
          ),

          // Ürün listesi
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, prodState) {
                if (prodState is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (prodState is ProductError) {
                  return Center(child: Text('Hata: ${prodState.message}'));
                } else if (prodState is ProductLoaded) {
                  return BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, searchState) {
                      final list =
                          searchState.query.isEmpty
                              ? prodState.products
                              : searchState.results;

                      if (list.isEmpty) {
                        return const Center(child: Text('Ürün bulunamadı'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final product = list[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                DetailScreen.routeName,
                                arguments: product,
                              );
                            },
                            child: Card(
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Resim
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Ürün adı
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product.ad,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Fiyat
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text('${product.fiyat} TL'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

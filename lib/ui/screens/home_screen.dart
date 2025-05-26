// lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/promo_carousel.dart';

import '../../blocs/product/product_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<SearchBloc>();
  }

  Widget _buildProductPage() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, prodState) {
        if (prodState is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prodState is ProductError) {
          return Center(child: Text('Hata: ${prodState.message}'));
        }
        if (prodState is ProductLoaded) {
          // Slider için ilk 3 ürünü alalım
          final promos = prodState.products.take(3).toList();
          return CustomScrollView(
            slivers: [
              // 1) Slider
              SliverToBoxAdapter(child: PromoCarousel(promos: promos)),
              // 2) Arama kutusu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (q) => _searchBloc.add(SearchQueryChanged(q)),
                  ),
                ),
              ),
              // 3) Ürünler grid’i
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, searchState) {
                    final list =
                        searchState.query.isEmpty
                            ? prodState.products
                            : searchState.results;
                    if (list.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Text('Ürün bulunamadı')),
                      );
                    }
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final product = list[i];
                        return GestureDetector(
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                DetailScreen.routeName,
                                arguments: product,
                              ),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    'http://kasimadalan.pe.hu/urunler/resimler/${product.resim}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                      }, childCount: list.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildProductPage(),
      const FavoritesScreen(),
      const CartScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.deepOrange.shade500,

      appBar: AppBar(
        title: const Text('Bootcamp Ecommerce'),
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sepetim',
          ),
        ],
      ),
    );
  }
}

// Gerekli Flutter kütüphaneleri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Tanımlı widget ve BLoC'lar
import '../widgets/promo_carousel.dart'; // üstte dönen promosyonlar
import '../../blocs/product/product_bloc.dart'; // ürün listesini yöneten bloc
import '../../blocs/search/search_bloc.dart'; // arama işlemini yöneten bloc
import 'detail_screen.dart'; // ürün detay sayfası

// Home ekranı Stateful çünkü arama için bir bloc'a erişilecek
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    // Arama için SearchBloc'a erişiyoruz
    _searchBloc = context.read<SearchBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst AppBar: Sayfa başlığı
      appBar: AppBar(
        title: const Text('Bootcamp Ecommerce'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueGrey,
      ),

      // Arka plana gradient efekti
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        // Ürünler ProductBloc'tan gelir
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, prodState) {
            // Yükleniyorsa spinner göster
            if (prodState is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Hata varsa mesaj göster
            if (prodState is ProductError) {
              return Center(child: Text('Hata: ${prodState.message}'));
            }

            // Yüklendiyse liste göster
            if (prodState is ProductLoaded) {
              final promos =
                  prodState.products.take(3).toList(); // İlk 3 ürün promosyon

              return CustomScrollView(
                slivers: [
                  // 📌 Promoların üstüne biraz boşluk
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // 🔁 Promo carousel (üstte dönen ürünler)
                  SliverToBoxAdapter(child: PromoCarousel(promos: promos)),

                  // 🔍 Arama kutusu
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Ara',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          // Her değişiklikte SearchBloc’a yeni query yollanır
                          onChanged:
                              (q) => _searchBloc.add(SearchQueryChanged(q)),
                        ),
                      ),
                    ),
                  ),

                  // 📦 Ürün grid listesi (arama varsa filtreli, yoksa tüm ürünler)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, searchState) {
                        final list =
                            searchState.query.isEmpty
                                ? prodState.products
                                : searchState.results;

                        // Eğer sonuç yoksa mesaj göster
                        if (list.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(child: Text('Ürün bulunamadı')),
                          );
                        }

                        // GridView ile ürünler listelenir
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final product = list[i];

                            return InkWell(
                              onTap:
                                  () => Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(
                                    DetailScreen.routeName,
                                    arguments:
                                        product, // Ürün detayına yönlendirme
                                  ),
                              child: Card(
                                elevation: 10,
                                color: Colors.amberAccent,
                                margin: const EdgeInsets.all(10),
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

            // Hiçbir state eşleşmezse boş widget döner
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

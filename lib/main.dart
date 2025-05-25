// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/services/web_service.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/favorites/favorites_bloc.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/detail_screen.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/favorite_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Tüm servis/repo örneklerini tek bir webService üzerinden oluşturalım:
  final webService = WebService();
  final productRepo = ProductRepository(webService);
  final cartRepo = CartRepository(webService);

  runApp(MyApp(productRepo: productRepo, cartRepo: cartRepo));
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepo;
  final CartRepository cartRepo;

  const MyApp({Key? key, required this.productRepo, required this.cartRepo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1) Ürünleri çeken Bloc
        BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(productRepo)..add(LoadProducts()),
        ),

        // 2) Sepet Bloc’u (LoadCart hemen tetikleniyor)
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(cartRepo)..add(LoadCart()),
        ),

        // 3) Arama Bloc’u
        BlocProvider<SearchBloc>(create: (_) => SearchBloc(productRepo)),

        // 4) Favoriler Bloc’u
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: MaterialApp(
        title: 'Bootcamp Ecommerce App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
        routes: {
          DetailScreen.routeName: (_) => const DetailScreen(),
          CartScreen.routeName: (_) => const CartScreen(),
          FavoritesScreen.routeName: (_) => const FavoritesScreen(),
        },
      ),
    );
  }
}

// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
        BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(productRepo)..add(LoadProducts()),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(cartRepo)..add(LoadCart()),
        ),
        BlocProvider<SearchBloc>(create: (_) => SearchBloc(productRepo)),
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bootcamp Ecommerce App',
        theme: ThemeData(
          // Figma’dan aldığın ana renk
          primaryColor: const Color(0xFF1E88E5),
          scaffoldBackgroundColor: Colors.white,
          // Google Fonts ile Poppins
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          // ElevatedButton teması
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // InputDecoration (arama çubuğu) teması
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIconColor: Colors.grey.shade600,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
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

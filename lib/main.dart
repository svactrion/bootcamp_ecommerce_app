import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Servis ve repository katmanları
import 'data/services/web_service.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/cart_repository.dart';

// Bloc'lar
import 'blocs/product/product_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/favorites/favorites_bloc.dart';

// Sayfalar
import 'ui/screens/detail_screen.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/favorite_screen.dart';
import 'ui/screens/main_screen.dart'; // ✅ Alt sekmeli ana ekran

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Uygulama başlamadan önce bağlam oluşturur

  // Web servis nesnesi oluşturuluyor (API erişimi için)
  final webService = WebService();

  // Repository'ler servisi kullanarak oluşturuluyor
  final productRepo = ProductRepository(webService);
  final cartRepo = CartRepository(webService);

  // Uygulama başlatılıyor
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
      // 🔹 Tüm BLoC'lar burada tanımlanır ve uygulamaya yayılır
      providers: [
        // Ürünler için bloc
        BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(productRepo)..add(LoadProducts()),
        ),
        // Sepet için bloc
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(cartRepo)..add(LoadCart()),
        ),
        // Arama işlemleri için bloc
        BlocProvider<SearchBloc>(create: (_) => SearchBloc(productRepo)),
        // Favoriler için bloc (local state)
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Debug etiketi kaldırılır
        title: 'Bootcamp Ecommerce App',
        theme: ThemeData(
          primaryColor: const Color(0xFF1E88E5),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          // Global buton stili
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Global input stil
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
        home: MainScreen(), // ✅ Ana ekran olarak sekmeli yapı
        routes: {
          // 🧭 Sayfa geçişleri için route tanımları
          DetailScreen.routeName: (_) => const DetailScreen(),
          CartScreen.routeName: (_) => const CartScreen(),
          FavoriteScreen.routeName: (_) => const FavoriteScreen(),
        },
      ),
    );
  }
}

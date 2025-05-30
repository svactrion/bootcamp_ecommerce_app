import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

// 3 ana ekranı ve global navController'ı içe aktarıyoruz
import 'home_screen.dart';
import 'cart_screen.dart';
import 'favorite_screen.dart';
import 'main_screen_controller.dart'; // ✅ global controller

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  // Her sekme için gösterilecek sayfaları döndüren metod
  List<Widget> _buildScreens() {
    return [
      HomeScreen(), // index 0 → Ana Sayfa
      FavoriteScreen(), // index 1 → Favoriler
      CartScreen(), // index 2 → Sepet
    ];
  }

  // Alt navigasyon çubuğundaki butonları tanımlıyoruz
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home), // Ev ikonu
        title: ("Home"), // Sekme başlığı
        activeColorPrimary: Colors.red, // Aktifken renk
        inactiveColorPrimary: Colors.grey, // Pasifken renk
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        title: ("Favorites"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.shopping_cart),
        title: ("Cart"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: navController, // Global olarak tanımlanan controller
      screens: _buildScreens(), // Gösterilecek ekranlar
      items: _navBarsItems(), // Alt barda görünecek sekmeler
      navBarStyle:
          NavBarStyle.style1, // Navigasyon çubuğu stili (style1 sade görünüm)
      // Diğer ayarlar
      handleAndroidBackButtonPress: true, // Android geri butonunu dinle
      resizeToAvoidBottomInset: true, // Klavye açılınca ekran küçülsün
      confineToSafeArea: true, // Güvenli alanda kalsın
      backgroundColor: Colors.white, // Alt bar arka plan rengi
      navBarHeight: kBottomNavigationBarHeight, // Varsayılan yükseklik
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(1), // Kenar yumuşatma
      ),
    );
  }
}

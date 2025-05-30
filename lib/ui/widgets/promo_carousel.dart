// lib/ui/widgets/promo_carousel.dart

import 'package:carousel_slider/carousel_slider.dart'; // Carousel kütüphanesi
import 'package:flutter/material.dart';
import '../../data/models/product.dart'; // Ürün modelini içe aktarıyoruz

// Bu widget, yatay kayan promosyon ürünleri göstermek için kullanılır
class PromoCarousel extends StatelessWidget {
  final List<Product> promos; // Gösterilecek promosyon ürün listesi

  const PromoCarousel({Key? key, required this.promos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: promos.length, // Kaç tane ürün gösterilecek
      options: CarouselOptions(
        height: 180, // Carousel yüksekliği
        viewportFraction: 0.8, // Her slaytın ekranın yüzde kaçını kaplayacağı
        enlargeCenterPage: true, // Ortadaki slaytın büyütülmesi
        autoPlay: true, // Otomatik geçiş etkin
      ),
      itemBuilder: (context, index, realIdx) {
        final p = promos[index]; // Her bir ürün
        return ClipRRect(
          borderRadius: BorderRadius.circular(12), // Köşeleri yumuşat
          child: Stack(
            children: [
              // 🔹 1) Ürün görseli
              Positioned.fill(
                child: Container(
                  color: Colors.grey[200], // Arka plan rengi (yüklenene kadar)
                  child: Image.network(
                    'http://kasimadalan.pe.hu/urunler/resimler/${p.resim}', // Görsel URL’si
                    fit: BoxFit.contain, // Görseli orantılı şekilde sığdır
                  ),
                ),
              ),

              // 🔹 2) Alt kısımda ürün adı ve fiyat gösteren şeffaf panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.black54, // Şeffaf siyah arka plan
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ürün adı
                      Expanded(
                        child: Text(
                          p.ad,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Taşarsa üç nokta koy
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Fiyat
                      Text(
                        '${p.fiyat} TL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

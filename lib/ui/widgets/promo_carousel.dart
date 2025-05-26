// lib/ui/widgets/promo_carousel.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class PromoCarousel extends StatelessWidget {
  final List<Product> promos;

  const PromoCarousel({Key? key, required this.promos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: promos.length,
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      itemBuilder: (context, index, realIdx) {
        final p = promos[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 1) Görseli contain ile alana sığdırıyoruz
              Positioned.fill(
                child: Container(
                  color: Colors.grey[200], // placeholder arkaplan
                  child: Image.network(
                    'http://kasimadalan.pe.hu/urunler/resimler/${p.resim}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 2) Alt kısımda şeffaf bilgi paneli
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.ad,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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

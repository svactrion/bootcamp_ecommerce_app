// lib/blocs/cart/cart_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartLoading()) {
    on<LoadCart>(_onLoadCart);
    on<AddProductToCart>(_onAddProduct);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveProductFromCart>(_onRemoveProduct);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final items = await repository.fetchCartItems();
      if (items.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(items));
      }
    } catch (e) {
      emit(const CartError('Sepet yüklenirken hata oluştu'));
    }
  }

  Future<void> _onAddProduct(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = await repository.fetchCartItems();

      // Ürün adını kullanarak eslesen mevcut satırı bul
      CartItem? existing;
      try {
        existing = items.firstWhere((item) => item.ad == event.product.ad);
      } catch (_) {
        existing = null;
      }

      if (existing != null) {
        // Aynı ürün zaten varsa: adeti birleştir
        final newQuantity = existing.siparisAdeti + event.quantity;

        final success = await repository.mergeCartItem(
          existingItem: existing,
          product: event.product,
          newQuantity: newQuantity,
        );
        if (!success) {
          emit(const CartError('Sepetteki ürün adedi güncellenemedi'));
          return;
        }
      } else {
        // Sepette yoksa normal ekle
        final success = await repository.addToCart(
          event.product,
          event.quantity,
        );
        if (!success) {
          emit(const CartError('Ürün sepete eklenemedi'));
          return;
        }
      }

      // Son durumda sepeti yeniden yükle
      add(LoadCart());
    } catch (e, s) {
      print('[_onAddProduct] Hata: $e\n$s');
      emit(const CartError('Ürün sepete eklenirken hata oluştu'));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      // 1) Önce fetchCartItems ile mevcut satırı bul (ad üzerinden)
      final items = await repository.fetchCartItems();
      CartItem? existing;
      try {
        existing = items.firstWhere((item) => item.sepetId == event.cartItemId);
      } catch (_) {
        existing = null;
      }

      if (existing == null) {
        // Böyle bir satır kalmamışsa hata ver
        emit(const CartError('Güncellenecek ürün bulunamadı'));
        return;
      }

      // 2) Eğer newQuantity < 1 ise direkt sil, yoksa "sil + ekle" yap
      if (event.newQuantity < 1) {
        final removed = await repository.removeFromCart(existing.sepetId);
        if (!removed) {
          emit(const CartError('Sepet öğesi silinemedi'));
          return;
        }
      } else {
        // Sil ve yeni adetle ekle
        final newQuantity = event.newQuantity;
        final success = await repository.mergeCartItem(
          existingItem: existing,
          product: Product( // Burada Product modelinin nesnesini oluşturabilmen için
            id: 0, // eğer Product modelinde id varsa, backend'de idye gerek yoksa 0 geç
            ad: existing.ad,
            resim: existing.resim,
            kategori: existing.kategori,
            fiyat: existing.fiyat,
            marka: existing.marka,
          ),
          newQuantity: newQuantity,
        );
        if (!success) {
          emit(const CartError('Adet güncellenirken hata oluştu'));
          return;
        }
      }

      // 3) Son durumda sepeti yeniden yükle
      add(LoadCart());
    } catch (e, s) {
      print('[_onUpdateQuantity] Hata: $e\n$s');
      emit(const CartError('Sepet öğesi güncellenirken hata oluştu'));
    }
  }

  Future<void> _onRemoveProduct(
    RemoveProductFromCart event,
    Emitter<CartState> emit,
  ) async {
    final success = await repository.removeFromCart(event.cartItemId);
    if (success) {
      add(LoadCart());
    } else {
      emit(const CartError('Ürün sepetten silinemedi'));
    }
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final items = await repository.fetchCartItems();
      for (final item in items) {
        await repository.removeFromCart(item.sepetId);
      }
      add(LoadCart());
    } catch (e, s) {
      print('[_onClearCart] Hata: $e\n$s');
      emit(const CartError('Sepet boşaltılırken hata oluştu'));
    }
  }
}

// lib/blocs/cart/cart_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/cart_item.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartLoading()) {
    on<LoadCart>(_onLoadCart);
    on<AddProductToCart>(_onAddProduct);
    on<RemoveProductFromCart>(_onRemoveProduct);
    on<ClearCart>(_onClearCart);

    // İstersen uygulama açılır açılmaz yüklesin:
    // add(LoadCart());
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await repository.fetchCartItems();
      if (items.isEmpty) {
        emit(CartEmpty()); // ← boş liste
      } else {
        emit(CartLoaded(items)); // ← dolu liste
      }
    } catch (e) {
      emit(const CartError('Sepet yüklenirken hata oluştu'));
    }
  }

  Future<void> _onAddProduct(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) async {
    final success = await repository.addToCart(event.product, event.quantity);
    if (success) {
      add(LoadCart());
    } else {
      emit(const CartError('Ürün sepete eklenemedi'));
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

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await repository.fetchCartItems();
      for (final item in items) {
        await repository.removeFromCart(item.sepetId);
      }
      add(LoadCart());
    } catch (e) {
      emit(const CartError('Sepet boşaltılırken hata oluştu'));
    }
  }
}

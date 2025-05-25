// lib/blocs/cart/cart_event.dart

part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddProductToCart extends CartEvent {
  final Product product;
  final int quantity;
  const AddProductToCart(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveProductFromCart extends CartEvent {
  final int cartItemId;
  const RemoveProductFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class ClearCart extends CartEvent {} // ← tüm sepeti boşalt

// lib/blocs/product/product_state.dart

part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

/// Ürünler yüklenirken gösterilecek durum
class ProductLoading extends ProductState {}

/// Ürünler başarıyla yüklendiğinde bu durum tetiklenir
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

/// Bir hata oluştuğunda bu durum tetiklenir
class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

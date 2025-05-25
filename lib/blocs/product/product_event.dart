// lib/blocs/product/product_event.dart

part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

/// Uygulama açıldığında veya yeniden yükleme istendiğinde tetiklenir
class LoadProducts extends ProductEvent {}

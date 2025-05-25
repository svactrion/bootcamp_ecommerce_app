part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

/// Veritabanındaki kayıtları yükle
class LoadFavorites extends FavoritesEvent {}

/// Yeni bir ürünü favoriye ekle
class AddFavorite extends FavoritesEvent {
  final Product product;
  const AddFavorite(this.product);

  @override
  List<Object?> get props => [product];
}

/// Favori ürün listesinden sil
class RemoveFavorite extends FavoritesEvent {
  final int productId;
  const RemoveFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}

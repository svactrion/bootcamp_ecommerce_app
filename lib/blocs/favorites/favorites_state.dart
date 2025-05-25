part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu, DB hazırlanıyor
class FavoritesInitial extends FavoritesState {}

/// Veritabanı açılırken gösterilecek durum
class FavoritesLoading extends FavoritesState {}

/// Favoriler yüklendi
class FavoritesLoaded extends FavoritesState {
  final List<Product> favorites;
  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

/// Hata durumu
class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

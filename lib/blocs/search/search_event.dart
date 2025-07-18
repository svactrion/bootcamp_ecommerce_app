part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

/// Kullanıcının arama çubuğuna her harf girdiğinde tetiklenir
class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

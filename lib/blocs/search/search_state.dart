part of 'search_bloc.dart';

class SearchState extends Equatable {
  final String query;
  final List<Product> results;

  const SearchState({this.query = '', this.results = const <Product>[]});

  SearchState copyWith({String? query, List<Product>? results}) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [query, results];
}

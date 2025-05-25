import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository repository;

  SearchBloc(this.repository) : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final allProducts = await repository.fetchAll();
    final filtered =
        allProducts
            .where(
              (p) => p.ad.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();
    emit(state.copyWith(query: event.query, results: filtered));
  }
}

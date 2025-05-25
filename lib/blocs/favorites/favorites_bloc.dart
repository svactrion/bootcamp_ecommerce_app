import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/product.dart';
part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  late Database _db;

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);

    // DB bağlantısını başlat ve kayıtları yükle
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            ad TEXT,
            resim TEXT,
            kategori TEXT,
            fiyat INTEGER,
            marka TEXT
          )
        ''');
      },
    );
    add(LoadFavorites());
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final maps = await _db.query('favorites');
      final favs =
          maps
              .map(
                (m) => Product(
                  id: m['id'] as int,
                  ad: m['ad'] as String,
                  resim: m['resim'] as String,
                  kategori: m['kategori'] as String,
                  fiyat: m['fiyat'] as int,
                  marka: m['marka'] as String,
                ),
              )
              .toList();
      emit(FavoritesLoaded(favs));
    } catch (e) {
      emit(FavoritesError('Favoriler yüklenirken hata: $e'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final p = event.product;
      await _db.insert('favorites', {
        'id': p.id,
        'ad': p.ad,
        'resim': p.resim,
        'kategori': p.kategori,
        'fiyat': p.fiyat,
        'marka': p.marka,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      add(LoadFavorites());
    } catch (e) {
      emit(FavoritesError('Favori eklenemedi: $e'));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [event.productId],
      );
      add(LoadFavorites());
    } catch (e) {
      emit(FavoritesError('Favori silinirken hata: $e'));
    }
  }
}

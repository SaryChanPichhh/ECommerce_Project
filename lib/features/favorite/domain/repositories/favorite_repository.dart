import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getFavorites({String? search, String? filter});
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}

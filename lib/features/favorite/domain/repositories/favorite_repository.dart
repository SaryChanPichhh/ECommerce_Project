import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getFavorites({String? search, String? filter});
}

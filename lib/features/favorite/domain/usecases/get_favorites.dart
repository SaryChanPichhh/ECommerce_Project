import '../entities/favorite.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository _repository;

  GetFavoritesUseCase(this._repository);

  Future<List<Favorite>> call({String? search, String? filter}) async {
    return await _repository.getFavorites(search: search, filter: filter);
  }
}

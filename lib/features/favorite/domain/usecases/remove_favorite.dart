import '../repositories/favorite_repository.dart';

class RemoveFavoriteUseCase {
  final FavoriteRepository _repository;

  RemoveFavoriteUseCase(this._repository);

  Future<void> call(String productId) async {
    return await _repository.removeFavorite(productId);
  }
}

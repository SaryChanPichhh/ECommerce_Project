import '../repositories/favorite_repository.dart';

class AddFavoriteUseCase {
  final FavoriteRepository _repository;

  AddFavoriteUseCase(this._repository);

  Future<void> call(String productId) async {
    return await _repository.addFavorite(productId);
  }
}

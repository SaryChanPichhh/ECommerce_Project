import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl({required FavoriteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;
  final favoritesList = List<Favorite>.of([
    Favorite(
      id: "0001",
      name: 'iPhone 16 Pro',
      description: 'Apple iPhone 16 Pro',
      price: 999.99,
      quantity: 1,
      category: 'Smartphone',
      imageUrl: 'https://example.com/iphone.jpg',
      isActive: true,
      favoritedAt: DateTime(2026, 8, 20, 10, 30),
    ),
  ]);

  @override
  Future<List<Favorite>> getFavorites({String? search, String? filter}) async {
    try {
      // return await _remoteDataSource.getFavorites(
      //   search: search,
      //   filter: filter,
      // );
      return favoritesList;
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}

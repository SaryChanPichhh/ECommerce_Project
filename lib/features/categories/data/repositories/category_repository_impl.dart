import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Category>> getCategories({String? parentId}) async {
    try {
      return await _remoteDataSource.getCategories(parentId: parentId);
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

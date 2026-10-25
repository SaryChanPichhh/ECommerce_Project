import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<List<Category>> call({String? parentId}) {
    return _repository.getCategories(parentId: parentId);
  }
}

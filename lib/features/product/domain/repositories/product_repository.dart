import 'package:pos_machine/core/repositories/base_repository.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';

abstract class ProductRepository extends BaseRepository {
  ProductRepository(super.cacheService);

  Future<List<Product>> getProducts({bool forceRefresh = false});
  Future<Product> getProductById(int id);
  Future<List<Product>> getProductsByCategory(
    String category, {
    bool forceRefresh = false,
  });
  Future<List<String>> getCategories({bool forceRefresh = false});
  Future<void> saveSelectedProducts(List<Product> products);
  Future<List<Product>> getSelectedProducts();
  Future<void> clearSelectedProducts();
}

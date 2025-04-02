import 'package:pos_machine/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> getProductsByCategory(String category);
}

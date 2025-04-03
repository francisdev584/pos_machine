import 'package:pos_machine/features/product/domain/entities/product.dart';

abstract class SaleRepository {
  Future<void> createSale(int userId, List<Product> products);
  Future<void> cancelSale(int saleId);
}

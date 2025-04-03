import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';

abstract class SaleRepository {
  Future<void> createSale(int userId, List<Product> products);
  Future<void> cancelSale(int saleId);
  Future<List<Sale>> getSales();
}

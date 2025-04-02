import 'package:pos_machine/features/seller/domain/entities/seller.dart';

abstract class SellerRepository {
  Future<List<Seller>> getSellers();
}

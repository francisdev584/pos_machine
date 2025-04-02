import 'package:dio/dio.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Dio _dio;

  SaleRepositoryImpl(Dio dio) : _dio = dio;

  @override
  Future<void> createSale(List<Product> products) async {
    try {
      final response = await _dio.post(
        '/carts',
        data: {
          'userId': 1,
          'date': DateTime.now().toIso8601String(),
          'products':
              products
                  .map((product) => {'productId': product.id, 'quantity': 1})
                  .toList(),
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao criar venda');
      }
    } catch (e) {
      throw Exception('Erro ao criar venda: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelSale(int saleId) async {
    try {
      final response = await _dio.delete('/carts/$saleId');

      if (response.statusCode != 200) {
        throw Exception('Falha ao cancelar venda');
      }
    } catch (e) {
      throw Exception('Erro ao cancelar venda: ${e.toString()}');
    }
  }
}

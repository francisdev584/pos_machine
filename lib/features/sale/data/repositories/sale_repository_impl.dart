import 'package:dio/dio.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Dio _dio;

  SaleRepositoryImpl(Dio dio) : _dio = dio;

  @override
  Future<void> createSale(int userId, List<Product> products) async {
    try {
      final response = await _dio.post(
        '/carts',
        data: {
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'products':
              products
                  .map(
                    (product) => {
                      'id': product.id,
                      'title': product.title,
                      'price': product.price,
                      'description': product.description,
                      'category': product.category,
                      'image': product.image,
                    },
                  )
                  .toList(),
        },
      );

      if (response.statusCode != 200) {
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

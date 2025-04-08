import 'package:dio/dio.dart';

import 'package:pos_machine/core/utils/error_handler.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
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
        throw AppException(
          'Falha ao criar venda: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao criar venda: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao criar venda: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelSale(int saleId) async {
    try {
      final response = await _dio.delete('/carts/$saleId');

      if (response.statusCode != 200) {
        throw AppException(
          'Falha ao cancelar venda: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao cancelar venda: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao cancelar venda: ${e.toString()}');
    }
  }

  @override
  Future<List<Sale>> getSales() async {
    try {
      final response = await _dio.get('/carts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final List<dynamic> products = json['products'];
          return Sale(
            id: json['id'],
            userId: json['userId'],
            products:
                products
                    .map<Product>(
                      (product) => Product(
                        id: product['productId'],
                        title: product['title'] ?? '',
                        price: (product['price'] ?? 0.0).toDouble(),
                        description: product['description'] ?? '',
                        category: product['category'] ?? '',
                        image: product['image'] ?? '',
                        rating: 0.0,
                        ratingCount: 0,
                      ),
                    )
                    .toList(),
          );
        }).toList();
      } else {
        throw AppException(
          'Falha ao carregar vendas: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao carregar vendas: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao carregar vendas: ${e.toString()}');
    }
  }
}

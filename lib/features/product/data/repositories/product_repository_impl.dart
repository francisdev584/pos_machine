import 'package:dio/dio.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final String _baseUrl;
  final Dio _dio;
  ProductRepositoryImpl(String baseUrl, Dio dio)
    : _baseUrl = baseUrl,
      _dio = dio;

  @override
  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/products/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Falha ao carregar produto');
      }
    } catch (e) {
      throw Exception('Erro ao carregar produto: ${e.toString()}');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('$_baseUrl/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos');
      }
    } catch (e) {
      throw Exception('Erro ao carregar produtos: ${e.toString()}');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('$_baseUrl/products/category/$category');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos da categoria');
      }
    } catch (e) {
      throw Exception(
        'Erro ao carregar produtos da categoria: ${e.toString()}',
      );
    }
  }
}

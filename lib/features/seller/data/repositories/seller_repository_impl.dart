// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';

class SellerRepositoryImpl implements SellerRepository {
  final Dio _dio;
  final String _baseUrl;

  SellerRepositoryImpl(String baseUrl, Dio dio)
    : _baseUrl = baseUrl,
      _dio = dio;

  @override
  Future<List<Seller>> getSellers() async {
    try {
      final response = await _dio.get('$_baseUrl/users');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Seller.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar vendedores');
      }
    } catch (e) {
      throw Exception('Erro ao carregar vendedores: ${e.toString()}');
    }
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';

class SellerRepositoryImpl extends SellerRepository {
  final Dio _dio;

  SellerRepositoryImpl(Dio dio, super.cacheService) : _dio = dio;

  @override
  Future<List<Seller>> getSellers() async {
    try {
      final response = await _dio.get('/users');

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

  @override
  Future<void> saveSelectedSeller(Seller seller) async {
    await saveToCache('selected_seller', seller, (s) => s.toJson());
  }

  @override
  Future<Seller?> getSelectedSeller() async {
    return await getFromCache('selected_seller', Seller.fromMap);
  }

  @override
  Future<void> clearSelectedSeller() async {
    await clearCache('selected_seller');
  }
}

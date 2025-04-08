// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

import 'package:pos_machine/core/utils/error_handler.dart';
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
        throw AppException(
          'Falha ao carregar vendedores: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao carregar vendedores: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao carregar vendedores: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSelectedSeller(Seller seller) async {
    try {
      await saveToCache('selected_seller', seller, (s) => s.toJson());
    } catch (e) {
      throw AppException(
        'Erro ao salvar vendedor selecionado: ${e.toString()}',
      );
    }
  }

  @override
  Future<Seller?> getSelectedSeller() async {
    try {
      return await getFromCache('selected_seller', Seller.fromMap);
    } catch (e) {
      throw AppException(
        'Erro ao recuperar vendedor selecionado: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearSelectedSeller() async {
    try {
      await clearCache('selected_seller');
    } catch (e) {
      throw AppException(
        'Erro ao limpar vendedor selecionado: ${e.toString()}',
      );
    }
  }
}

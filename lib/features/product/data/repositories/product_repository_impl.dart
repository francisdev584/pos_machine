import 'package:dio/dio.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final Dio _dio;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  ProductRepositoryImpl(Dio dio, super.cacheService) : _dio = dio;

  @override
  Future<Product> getProductById(int id, {bool forceRefresh = false}) async {
    try {
      final cacheKey = 'product_$id';
      if (!forceRefresh) {
        final cachedProduct = await getFromCache<Map<String, dynamic>>(
          cacheKey,
          (json) => json,
        );
        if (cachedProduct != null) {
          return Product.fromJson(cachedProduct);
        }
      }

      final response = await _dio.get('/products/$id');
      final product = Product.fromJson(response.data as Map<String, dynamic>);

      await saveToCache(
        cacheKey,
        product,
        (product) => product.toJson(),
        expiration: _cacheExpiration,
      );
      return product;
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedProducts = await getFromCache<List<dynamic>>(
          'products',
          (json) =>
              (json['products'] as List)
                  .map((item) => Product.fromJson(item as Map<String, dynamic>))
                  .toList(),
        );
        if (cachedProducts != null) {
          return cachedProducts.cast<Product>();
        }
      }

      final response = await _dio.get('/products');
      final products =
          (response.data as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

      await saveToCache(
        'products',
        products,
        (products) => {'products': products.map((p) => p.toJson()).toList()},
        expiration: _cacheExpiration,
      );
      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = 'products_category_$category';
      if (!forceRefresh) {
        final cachedProducts = await getFromCache<List<dynamic>>(
          cacheKey,
          (json) =>
              (json['products'] as List)
                  .map((item) => Product.fromJson(item as Map<String, dynamic>))
                  .toList(),
        );
        if (cachedProducts != null) {
          return cachedProducts.cast<Product>();
        }
      }

      // Busca todos os produtos e filtra por categoria
      final allProducts = await getProducts(forceRefresh: forceRefresh);
      final filteredProducts =
          allProducts.where((p) => p.category == category).toList();

      await saveToCache(
        cacheKey,
        filteredProducts,
        (products) => {'products': products.map((p) => p.toJson()).toList()},
        expiration: _cacheExpiration,
      );
      return filteredProducts;
    } catch (e) {
      throw Exception('Erro ao buscar produtos por categoria: $e');
    }
  }

  @override
  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedCategories = await getFromCache<List<dynamic>>(
          'categories',
          (json) => (json['categories'] as List).cast<String>(),
        );
        if (cachedCategories != null) {
          return cachedCategories.cast<String>();
        }
      }

      // Busca todos os produtos e extrai categorias únicas
      final allProducts = await getProducts(forceRefresh: forceRefresh);
      final categories =
          allProducts.map((p) => p.category).toSet().toList()..sort();

      await saveToCache(
        'categories',
        categories,
        (categories) => {'categories': categories},
        expiration: _cacheExpiration,
      );
      return categories;
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  @override
  Future<void> saveSelectedProducts(List<Product> products) async {
    await saveToCache(
      'selected_products',
      products,
      (products) => {'products': products.map((p) => p.toJson()).toList()},
      expiration: null, // Cache de produtos selecionados não expira
    );
  }

  @override
  Future<List<Product>> getSelectedProducts() async {
    final cachedProducts = await getFromCache<List<dynamic>>(
      'selected_products',
      (json) =>
          (json['products'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
    return cachedProducts?.cast<Product>() ?? [];
  }

  @override
  Future<void> clearSelectedProducts() async {
    await clearCache('selected_products');
  }
}

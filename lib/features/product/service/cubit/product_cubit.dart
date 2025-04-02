import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;
  List<Product> _allProducts = [];
  List<String> _categories = [];

  ProductCubit({required ProductRepository repository})
    : _repository = repository,
      super(ProductInitial()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    emit(ProductLoading());
    try {
      _allProducts = await _repository.getProducts();
      _categories = await _repository.getCategories();

      emit(ProductLoaded(products: _allProducts, categories: _categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    emit(ProductLoading());

    try {
      _allProducts = await _repository.getProducts(forceRefresh: forceRefresh);
      _categories = await _repository.getCategories(forceRefresh: forceRefresh);

      emit(ProductLoaded(products: _allProducts, categories: _categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> loadProductsByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    emit(ProductLoading());

    try {
      final products = await _repository.getProductsByCategory(
        category,
        forceRefresh: forceRefresh,
      );

      emit(ProductLoaded(products: products, categories: _categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void searchProducts(String query) {
    if (state is ProductLoaded) {
      final filteredProducts =
          _allProducts.where((product) {
            final searchLower = query.toLowerCase();
            return product.title.toLowerCase().contains(searchLower) ||
                product.id.toString().contains(searchLower);
          }).toList();

      emit(ProductLoaded(products: filteredProducts, categories: _categories));
    }
  }
}

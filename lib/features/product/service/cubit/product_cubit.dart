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
      super(ProductInitial());

  Future<void> loadProducts({bool forceRefresh = false}) async {
    emit(ProductLoading());

    try {
      _allProducts = await _repository.getProducts(forceRefresh: forceRefresh);
      _categories = await _repository.getCategories(forceRefresh: forceRefresh);

      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(
          ProductLoaded(
            products: _allProducts,
            categories: _categories,
            selectedProducts: currentState.selectedProducts,
          ),
        );
      } else {
        emit(
          ProductLoaded(
            products: _allProducts,
            categories: _categories,
            selectedProducts: [],
          ),
        );
      }
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

      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(
          ProductLoaded(
            products: products,
            categories: _categories,
            selectedProducts: currentState.selectedProducts,
          ),
        );
      } else {
        emit(
          ProductLoaded(
            products: products,
            categories: _categories,
            selectedProducts: [],
          ),
        );
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void searchProducts(String query) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final filteredProducts =
          _allProducts.where((product) {
            final searchLower = query.toLowerCase();
            return product.title.toLowerCase().contains(searchLower) ||
                product.id.toString().contains(searchLower);
          }).toList();

      emit(
        ProductLoaded(
          products: filteredProducts,
          categories: _categories,
          selectedProducts: currentState.selectedProducts,
        ),
      );
    }
  }

  void toggleProduct(Product product) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final selectedProducts = List<Product>.from(
        currentState.selectedProducts,
      );

      if (selectedProducts.contains(product)) {
        selectedProducts.remove(product);
      } else if (selectedProducts.length < 10) {
        selectedProducts.add(product);
      }

      emit(
        ProductLoaded(
          products: currentState.products,
          categories: _categories,
          selectedProducts: selectedProducts,
        ),
      );
    }
  }

  Future<void> saveSelectedProducts() async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      await _repository.saveSelectedProducts(currentState.selectedProducts);
    }
  }

  Future<void> loadSelectedProducts() async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final selectedProducts = await _repository.getSelectedProducts();

      emit(
        ProductLoaded(
          products: currentState.products,
          categories: _categories,
          selectedProducts: selectedProducts,
        ),
      );
    }
  }

  Future<void> clearSelectedProducts() async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      await _repository.clearSelectedProducts();

      emit(
        ProductLoaded(
          products: currentState.products,
          categories: _categories,
          selectedProducts: [],
        ),
      );
    }
  }
}

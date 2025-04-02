import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;
  List<Product> _allProducts = [];

  ProductCubit({required ProductRepository repository})
    : _repository = repository,
      super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());

    try {
      _allProducts = await _repository.getProducts();
      emit(ProductLoaded(products: _allProducts));
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
          selectedProducts: selectedProducts,
        ),
      );
    }
  }
}

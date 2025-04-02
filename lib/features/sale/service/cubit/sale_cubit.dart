import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';

part 'sale_state.dart';

class SaleCubit extends Cubit<SaleState> {
  final SaleRepository _repository;
  final List<Product> _selectedProducts = [];
  final Map<Product, int> _quantities = {};

  SaleCubit({required SaleRepository repository})
    : _repository = repository,
      super(SaleInitial());

  void toggleProduct(Product product) {
    if (_selectedProducts.contains(product)) {
      _selectedProducts.remove(product);
      _quantities.remove(product);
    } else {
      _selectedProducts.add(product);
      _quantities[product] = 1;
    }
    emit(
      SaleLoaded(
        selectedProducts: List.from(_selectedProducts),
        quantities: Map.from(_quantities),
      ),
    );
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _quantities.remove(product);
    } else {
      _quantities[product] = quantity;
    }
    emit(
      SaleLoaded(
        selectedProducts: List.from(_selectedProducts),
        quantities: Map.from(_quantities),
      ),
    );
  }

  void removeProduct(Product product) {
    _selectedProducts.remove(product);
    _quantities.remove(product);
    emit(
      SaleLoaded(
        selectedProducts: List.from(_selectedProducts),
        quantities: Map.from(_quantities),
      ),
    );
  }

  void clearCart() {
    _selectedProducts.clear();
    _quantities.clear();
    emit(SaleInitial());
  }

  Future<void> finalizeSale() async {
    if (state is SaleLoaded) {
      try {
        await _repository.createSale(_selectedProducts);
        clearCart();
        emit(SaleSuccess());
      } catch (e) {
        emit(SaleError(e.toString()));
      }
    }
  }
}

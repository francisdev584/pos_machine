import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';

part 'sale_state.dart';

class SaleCubit extends Cubit<SaleState> {
  final SaleRepository _repository;
  List<Product> _products = [];

  SaleCubit({required SaleRepository repository})
    : _repository = repository,
      super(SaleInitial());

  void setProducts(List<Product> products) {
    _products = products;
    emit(SaleLoaded(products: _products));
  }

  void removeProduct(Product product) {
    _products.remove(product);
    emit(SaleLoaded(products: _products));
  }

  Future<void> finalizeSale() async {
    if (state is SaleLoaded) {
      try {
        await _repository.createSale(_products);
        emit(SaleSuccess());
      } catch (e) {
        emit(SaleError(e.toString()));
      }
    }
  }
}

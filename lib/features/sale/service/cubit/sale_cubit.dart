import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';
import 'package:pos_machine/features/seller/domain/entities/seller.dart';

part 'sale_state.dart';

class SaleCubit extends Cubit<SaleState> {
  static const int maxProducts = 10;

  final SaleRepository _repository;
  Sale sale = Sale(userId: 0, products: []);

  SaleCubit({required SaleRepository repository})
    : _repository = repository,
      super(SaleInitial());

  void toggleProduct(Seller seller, Product product, {BuildContext? context}) {
    if (sale.userId == 0) {
      sale = sale.copyWith(userId: seller.id);
    }
    if (sale.products.contains(product)) {
      sale.products.remove(product);
    } else {
      if (sale.products.length >= maxProducts) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Limite máximo de 10 produtos por venda atingido'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      sale.products.add(product);
    }
    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  void removeProduct(Product product) {
    sale.products.remove(product);
    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  void clearCart() {
    sale.products.clear();
    sale = sale.copyWith(userId: 0);
    emit(SaleInitial());
  }

  Future<void> finalizeSale() async {
    if (state is SaleLoaded) {
      try {
        await _repository.createSale(sale.userId, sale.products);
        clearCart();
        emit(SaleSuccess());
      } catch (e) {
        emit(SaleError(e.toString()));
      }
    }
  }
}

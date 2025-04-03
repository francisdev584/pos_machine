import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';

part 'admin_sale_state.dart';

class AdminSaleCubit extends Cubit<AdminSaleState> {
  final SaleRepository _repository;

  AdminSaleCubit({required SaleRepository repository})
    : _repository = repository,
      super(AdminSaleInitial());

  Future<void> loadSales() async {
    emit(AdminSaleLoading());
    try {
      final sales = await _repository.getSales();
      emit(AdminSaleLoaded(sales: sales));
    } catch (e) {
      emit(AdminSaleError(e.toString()));
    }
  }

  Future<void> cancelSale(int saleId) async {
    try {
      await _repository.cancelSale(saleId);
      await loadSales();
    } catch (e) {
      emit(AdminSaleError(e.toString()));
    }
  }
}

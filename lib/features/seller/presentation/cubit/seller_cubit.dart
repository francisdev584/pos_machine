import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _repository;

  SellerCubit({required SellerRepository repository})
    : _repository = repository,
      super(SellerInitial()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    emit(SellerLoading());
    try {
      final sellers = await _repository.getSellers();
      final cachedSeller = await _repository.getSelectedSeller();
      emit(SellerLoaded(sellers: sellers, selectedSeller: cachedSeller));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> loadSellers() async {
    emit(SellerLoading());
    try {
      final sellers = await _repository.getSellers();
      final cachedSeller = await _repository.getSelectedSeller();
      emit(SellerLoaded(sellers: sellers, selectedSeller: cachedSeller));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> selectSeller(Seller seller) async {
    if (state is SellerLoaded) {
      final currentState = state as SellerLoaded;
      await _repository.saveSelectedSeller(seller);
      emit(SellerLoaded(sellers: currentState.sellers, selectedSeller: seller));
    }
  }
}

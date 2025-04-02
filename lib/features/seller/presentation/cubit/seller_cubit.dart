import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _repository;

  SellerCubit({required SellerRepository repository})
    : _repository = repository,
      super(SellerInitial());

  Future<void> loadSellers() async {
    emit(SellerLoading());

    try {
      final sellers = await _repository.getSellers();
      emit(SellerLoaded(sellers: sellers));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  void selectSeller(Seller seller) {
    if (state is SellerLoaded) {
      final currentState = state as SellerLoaded;
      emit(SellerLoaded(sellers: currentState.sellers, selectedSeller: seller));
    }
  }
}

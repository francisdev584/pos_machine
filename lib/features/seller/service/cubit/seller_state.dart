part of 'seller_cubit.dart';

abstract class SellerState extends Equatable {
  const SellerState();

  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

class SellerLoading extends SellerState {}

class SellerLoaded extends SellerState {
  final List<Seller> sellers;
  final Seller? selectedSeller;

  const SellerLoaded({required this.sellers, this.selectedSeller});

  @override
  List<Object?> get props => [sellers, selectedSeller];
}

class SellerError extends SellerState {
  final String message;

  const SellerError(this.message);

  @override
  List<Object?> get props => [message];
}

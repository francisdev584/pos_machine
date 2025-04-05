part of 'sale_cubit.dart';

abstract class SaleState extends Equatable {
  const SaleState({key});

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {}

class SaleLoaded extends SaleState {
  final Sale sale;

  const SaleLoaded({required this.sale});

  double get total {
    return sale.products.fold(0, (sum, product) => sum + (product.price * 1));
  }

  @override
  List<Object?> get props => [sale];
}

class SaleCanProceedToPayment extends SaleState {
  final Sale sale;

  const SaleCanProceedToPayment({required this.sale});
  double get total {
    return sale.products.fold(0, (sum, product) => sum + (product.price * 1));
  }
}

class SaleProcessing extends SaleState {}

class SaleSuccess extends SaleState {}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}

class SaleCanNotProceedToPaymentError extends SaleState {
  final String message;

  const SaleCanNotProceedToPaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

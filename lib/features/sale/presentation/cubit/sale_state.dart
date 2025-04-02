part of 'sale_cubit.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {}

class SaleLoaded extends SaleState {
  final List<Product> products;

  const SaleLoaded({required this.products});

  double get total {
    return products.fold(0, (sum, product) => sum + product.price);
  }

  @override
  List<Object?> get props => [products];
}

class SaleSuccess extends SaleState {}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}

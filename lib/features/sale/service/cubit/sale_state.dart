part of 'sale_cubit.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {}

class SaleLoaded extends SaleState {
  final List<Product> selectedProducts;
  final Map<Product, int> quantities;

  const SaleLoaded({required this.selectedProducts, required this.quantities});

  double get total {
    return selectedProducts.fold(
      0,
      (sum, product) => sum + (product.price * (quantities[product] ?? 1)),
    );
  }

  @override
  List<Object?> get props => [selectedProducts, quantities];
}

class SaleSuccess extends SaleState {}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}
